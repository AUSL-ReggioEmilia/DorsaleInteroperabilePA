CREATE FUNCTION [dbo].[GetModificaPazienteByLivelloAttendibilita](
	@Id AS uniqueidentifier
	)
RETURNS bit
AS
BEGIN
	DECLARE @Ret AS bit
	DECLARE @LivelloAttendibilitaPaziente AS tinyint

	---------------------------------------------------
	--  Confronto il livello di attendibilita paziente con quello Ui
	---------------------------------------------------

	SELECT @LivelloAttendibilitaPaziente = LivelloAttendibilita
		FROM Pazienti
		WHERE Id = @Id

	IF @LivelloAttendibilitaPaziente <= dbo.ConfigPazientiLivelloAttendibilitaUi()
		SET @Ret = 1
	ELSE
		SET @Ret = 0

	RETURN @Ret
END




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[GetModificaPazienteByLivelloAttendibilita] TO [DataAccessUi]
    AS [dbo];

