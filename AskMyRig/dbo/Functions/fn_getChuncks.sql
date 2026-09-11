-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION dbo.fn_getChuncks
(	
	-- Add the parameters for the function here
	@p1 INT = 0, 
	@P2 INT = 0
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
	SELECT * from Chunks
)

GO

