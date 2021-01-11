
CREATE FUNCTION [dbo].[GetPermessoFusioneByFasciaOraria]()
RETURNS bit
AS
BEGIN
/*
	Questa function viene effettivamente usata dalle SP <CercaOrAggiunge>
	per fare le fusioni al volo e dalla PazientiBaseMerge() sempre per fare
	le fusioni al volo.
	
	Ora le fusioni al volo devono essere fatte sempre!

*/
	RETURN 1

END
