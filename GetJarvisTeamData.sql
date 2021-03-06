USE [Jarvis]
GO
/****** Object:  StoredProcedure [dbo].[GetJarvisTeamData]    Script Date: 22/11/2019 08:55:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Dave Johnson
-- Create date: 11/10/2019
-- Description:	Queries Jarvis DB to get Practice Area, Business Unit, Group and Team data
-- =============================================
ALTER PROCEDURE [dbo].[GetJarvisTeamData]
(
	@QueryType VARCHAR(250)
)
AS
BEGIN	
	SET NOCOUNT ON   		
	
	IF @QueryType = 'Practice Area' /*View Practice Areas (Level 5) in Jarvis*/
	BEGIN
		SELECT 
			practiceArea.TeamId AS PracticeAreaTeamId,
			practiceArea.TeamName AS PracticeAreaName,
			[Owner].OwnerId AS OperationsDirectorOwnerId,
			[Owner].OwnerTitle AS OperationsDirectorName
		FROM 	
			[Team] practiceArea
			INNER JOIN TeamOwner teamOwner
				ON practiceArea.TeamId = teamOwner.TeamId
			INNER JOIN [Owner] [owner]
				ON [owner].OwnerId = teamOwner.OwnerId		
		WHERE 
			practiceArea.TopLevelTeamId = (SELECT TeamId FROM Team WHERE TeamName = 'Practice Area')
			AND [owner].OwnerName = 'Operations Director'
		ORDER BY
			practiceArea.TeamName,
			[Owner].OwnerTitle
	END
	IF @QueryType = 'Business Unit' /*View Business Units (Level 4) in Jarvis */
	BEGIN						
		SELECT 
			businessUnit.TeamId AS BusinessUnitTeamId,
			IIF(practiceArea.TeamName IS NULL, '', practiceArea.TeamName) AS PracticeAreaName,
			IIF(businessUnit.TeamName IS NULL, '', businessUnit.TeamName) AS BusinessUnitName,
			[Owner].OwnerId AS BusinessUnitDirectorOwnerId,
			[Owner].OwnerTitle AS BusinessUnitDirector
			
		FROM 
			[Team] businessUnit
			LEFT JOIN [Team] practiceArea
				ON businessUnit.ParentId = practiceArea.TeamId
			INNER JOIN TeamOwner teamOwner
				ON businessUnit.TeamId = teamOwner.TeamId
			INNER JOIN [Owner] [owner]
				ON [owner].OwnerId = teamOwner.OwnerId		
		WHERE 
			businessUnit.TopLevelTeamId = (SELECT TeamId FROM Team WHERE TeamName = 'Business Unit')
			AND [owner].OwnerName = 'Business Unit Director'
		ORDER BY
			practiceArea.TeamName,
			businessUnit.TeamName,
			[Owner].OwnerTitle	
	END
	IF @QueryType = 'Group' /*View Team Groups (Level 3) in Jarvis*/
	BEGIN
		SELECT 
			[group].TeamId AS GroupTeamId,
			IIF(practiceArea.TeamName IS NULL, '', practiceArea.TeamName) AS PracticeAreaName,
			IIF(businessUnit.TeamName IS NULL, '', businessUnit.TeamName) AS BusinessUnitName,
			[group].TeamName AS GroupName
		FROM 
			[Team] [group]
			LEFT JOIN [Team] businessUnit
				ON [group].ParentId = businessUnit.TeamId
			LEFT JOIN [Team] practiceArea
				ON businessUnit.ParentId = practiceArea.TeamId
		WHERE 
			[group].TopLevelTeamId = (SELECT TeamId FROM Team WHERE TeamName = 'Group')
	END

	IF @QueryType = 'Team' /*View Teams (Level 2) in Jarvis*/
	BEGIN
		SELECT 
			[team].TeamId,
			IIF(practiceArea.TeamName IS NULL, '', practiceArea.TeamName) AS PracticeAreaName,
			IIF(businessUnit.TeamName IS NULL, '', businessUnit.TeamName) AS BusinessUnitName,
			[group].TeamName AS GroupName,
			[team].TeamName AS TeamName,
			[Owner].OwnerId AS TeamLeaderOwnerId,
			[Owner].OwnerTitle AS TeamLeaderName			
		FROM 
			Team [team]
			LEFT JOIN Team [group]
				ON [team].ParentId = [group].TeamId
			LEFT JOIN [Team] businessUnit
				ON [group].ParentId = businessUnit.TeamId
			INNER JOIN TeamOwner teamOwner
				ON [team].TeamId = teamOwner.TeamId
			INNER JOIN [Owner] [owner]
				ON [owner].OwnerId = teamOwner.OwnerId
			LEFT JOIN [Team] practiceArea
				ON businessUnit.ParentId = practiceArea.TeamId
		WHERE 
			[team].TopLevelTeamId = (SELECT TeamId FROM Team WHERE TeamName = 'Team')
			AND [owner].OwnerName = 'Team Leader'
		ORDER BY
			practiceArea.TeamName,
			businessUnit.TeamName,
			[group].TeamName,
			[team].TeamName,
			[Owner].OwnerTitle
	END	
	
	IF @QueryType = 'User' /*View Users (Level 1) in Jarvis*/
	BEGIN
		SELECT 
			u.UserId,
			u.PayrollNumber,
			u.Surname,
			u.FirstName,
			u.JobTitle,
			t.TeamId,
			t.TeamName,
			u.Email,
			u.StartDate,
			u.[Location],
			u.PhoneNumber		
		FROM
			[User] u
			INNER JOIN TeamUser tu
				ON tu.UserId = u.UserId
			INNER JOIN Team t
				ON t.TeamId = tu.TeamId
		ORDER BY
			u.Surname
	END	
END



