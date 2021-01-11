
CREATE FUNCTION [dbo].[GetWsDescrizioneStato2]
(@idOrdineTestata UNIQUEIDENTIFIER)
RETURNS VARCHAR (MAX)
AS
BEGIN
	DECLARE @returnValue VARCHAR(MAX) = '';
	DECLARE @dataModificaErogato as datetime2(0)
	DECLARE @stato as varchar(max)

	SELECT @stato=StatoOrderEntry from dbo.OrdiniTestate (nolock) where ID = @idOrdineTestata

	IF @stato <> 'SR'
		BEGIN
			--solo richiedente

			IF @stato = 'CA' return 'Cancellato'

			if (select count(*) from dbo.OrdiniErogatiTestate (nolock) where IDOrdineTestata = @idOrdineTestata and StatoRisposta ='AE') > 0
				begin
					Return 'Errato'	
				end
			else
				begin
					return 'Inserito'
				end
		END
	ELSE
		BEGIN
		--erogante

		DECLARE @statoErogato as varchar(max) = dbo.GetMinStatoErogatoTestateOrderEntry(@idOrdineTestata)

		IF @statoErogato IS NULL
		BEGIN
			if (select count(*) from dbo.OrdiniErogatiTestate (nolock) where IDOrdineTestata = @idOrdineTestata and StatoRisposta ='AE') > 0
			begin
				Return 'Errato'
			end
		ELSE
			begin
				Return 'Inoltrato'
			end
		END

		IF @statoErogato = 'IC'
			BEGIN
			IF @stato = 'CA' return 'Cancellato'

				IF (SELECT COUNT(*) from dbo.OrdiniRigheErogate (nolock)
						inner join OrdiniErogatiTestate (nolock)
							on OrdiniRigheErogate.IDOrdineErogatoTestata = OrdiniErogatiTestate.ID
						where OrdiniErogatiTestate.IDOrdineTestata = @idOrdineTestata AND OrdiniRigheErogate.StatoOrderEntry <> 'CM') > 0 
					BEGIN
						IF (SELECT COUNT(*) from dbo.OrdiniRigheErogate (nolock)
							inner join OrdiniErogatiTestate (nolock)
								on OrdiniRigheErogate.IDOrdineErogatoTestata = OrdiniErogatiTestate.ID
							where OrdiniErogatiTestate.IDOrdineTestata = @idOrdineTestata AND OrdiniRigheErogate.StatoOrderEntry = 'IP') = 0 
						BEGIN
							IF (SELECT COUNT(*) from dbo.OrdiniRigheErogate (nolock)
								inner join OrdiniErogatiTestate (nolock)
									on OrdiniRigheErogate.IDOrdineErogatoTestata = OrdiniErogatiTestate.ID
								where OrdiniErogatiTestate.IDOrdineTestata = @idOrdineTestata AND OrdiniRigheErogate.StatoOrderEntry = 'IC') = 0 
								return 'Inoltrato'
							ELSE
								return 'Incarico'
						END
						ELSE
							return 'Programmato' 
					END
					ELSE 
						return 'Erogato'	
			END
		ELSE
			BEGIN
				declare @codiceStato varchar(16)
				select @codiceStato = StatoOrderEntry from dbo.OrdiniErogatiTestate (nolock) where IDOrdineTestata = @idOrdineTestata

				if @codiceStato = 'CA' return 'Cancellato'
				if @codiceStato = 'CM' return 'Erogato'
				if @codiceStato = 'IC' return 'Incarico'
				if @codiceStato = 'IP' return 'Programmato'

				return @codiceStato
			END
		END

	return 'Errato'
END
