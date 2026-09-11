-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION dbo.fn_GetChuncksEscalar
(
	-- Add the parameters for the function here
	@Param1 int
)
RETURNS INT
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ResultVar INT;

	-- Add the T-SQL statements to compute the return value here
	SELECT @ResultVar = (select top 1 Chunks.ManualId from Chunks)

	-- Return the result of the function
	RETURN @ResultVar

END

GO

