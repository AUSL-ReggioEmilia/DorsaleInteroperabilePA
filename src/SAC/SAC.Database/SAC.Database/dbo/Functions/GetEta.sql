CREATE FUNCTION dbo.GetEta(@DataNascita DATETIME,@Now DATETIME)
RETURNS int AS
BEGIN
DECLARE @AnniEta INT
	SELECT 
		@AnniEta = DATEDIFF(yy, @DataNascita, @Now) - 
			(CASE WHEN 
				(
					DATEPART(m, @DataNascita) > DATEPART(m, @Now)) 
				OR 
					(DATEPART(m, @DataNascita) = DATEPART(m, @Now) AND DATEPART(d, @DataNascita) > DATEPART(d, @Now)
				)
				THEN 1 ELSE 0 END
			)
	RETURN @AnniEta
END

