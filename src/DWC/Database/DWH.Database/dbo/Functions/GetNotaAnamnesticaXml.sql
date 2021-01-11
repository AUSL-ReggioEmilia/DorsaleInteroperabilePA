






-- =============================================
-- Author:		ETTORE
-- Create date: 2017-11-22
-- Description:	Restituisce l'XML per l'output di una nota anamnestica
--				Utilizza anche la DataPartizione
-- Modify date: 2019-08-27 - ETTORE: aggiunto la valorizzazione del campo DataFineValidita nell'elenco delle note
-- =============================================
CREATE FUNCTION [dbo].[GetNotaAnamnesticaXml]
(
	@Id uniqueidentifier
	, @DataPartizione smalldatetime
)
RETURNS XML
AS
BEGIN
/*
 Ritorna un segmento XML ddella nota anamnestica e tutte le note del paziente
	namespace = http://schemas.progel.it/SQL/Dwh/QueueNotaAnamnesticaOutput/1.0
*/
DECLARE @XmlAnagrafica xml
DECLARE @XmlNotaAnamnestica xml
		
	IF NOT @ID IS NULL
	BEGIN
		--
		-- NoteAnamnestiche attributi
		--
		DECLARE @XmlAttributiNoteAnamnestiche AS xml
		SET @XmlAttributiNoteAnamnestiche = (			
			CONVERT(XML, (
							SELECT Attributo.Nome, Attributo.Valore
							FROM store.NoteAnamnesticheAttributi AS Attributo INNER JOIN store.NoteAnamnesticheBase AS NA
										ON Attributo.IdNoteAnamnesticheBase = NA.Id
										AND (Attributo.DataPartizione = NA.DataPartizione)
							WHERE NA.ID = @Id and NA.Datapartizione = @DataPartizione
							ORDER BY Nome
							FOR XML AUTO
				)) 
		)

		--
		-- Tutte le note del paziente
		--
		DECLARE @IdPazienteAttivo UNIQUEIDENTIFIER
		SELECT @IdPazienteAttivo = dbo.GetPazienteAttivoByIdSac(IdPaziente) 
		FROM store.NoteAnamnestiche WHERE Id = @ID AND DataPartizione = @DataPartizione
		--
		-- Calcolo la catena di fusione
		--
		DECLARE @TablePazienti as TABLE (Id uniqueidentifier)
		INSERT INTO @TablePazienti(Id)
		SELECT Id FROM dbo.GetPazientiDaCercareByIdSac(@IdPazienteAttivo)	

		--
		-- Converto in XML l'elenco delle note del paziente
		--
		DECLARE @XmlTutteLeNoteAnamnestiche AS XML
		SET @XmlTutteLeNoteAnamnestiche  = ( CONVERT(XML, (
							SELECT 
								DataNota
								, DataFineValidita --MODIFICA ETTORE 2019-08-27
								, AziendaErogante
								, SistemaErogante
								, TipoDescrizione 
								, ContenutoText
							FROM store.NoteAnamnestiche AS Nota
								INNER JOIN @TablePazienti AS Pazienti
									ON IdPaziente = Pazienti.Id
							WHERE 
								--
								-- Non restituisco le note nello stato "CANCELLATO"
								--
								Nota.StatoCodice <> 3 
								--
								-- Non restituisco le note anamnestiche che non sono più valide
								--
								AND CASE WHEN Nota.DataFineValidita IS NULL THEN GETDATE()
											ELSE CAST(Nota.DataFineValidita AS DATE) 
										END >= GETDATE()

							ORDER BY DataNota 
							FOR XML AUTO, ELEMENTS
						)
					)
				)
		--
		-- NoteAnamnestiche
		--
		;WITH XMLNAMESPACES ('http://schemas.progel.it/SQL/Dwh/QueueNotaAnamnesticaOutput/1.0' as ns0)
		SELECT @XmlNotaAnamnestica = (
			SELECT 	"ns0:NotaAnamnestica".Id
					,@IdPazienteAttivo AS IdPaziente

				-- Ricavo CodiceAnagraficaCentrale e NomeAnagraficaCentrale
				, Attributi.value('(/Attributi/Attributo[@Nome="CodiceAnagraficaCentrale"]/@Valore)[1]', 'varchar(64)') AS CodiceAnagraficaCentrale
				, Attributi.value('(/Attributi/Attributo[@Nome="NomeAnagraficaCentrale"]/@Valore)[1]', 'varchar(64)') AS NomeAnagraficaCentrale

				-- Ricavo paziente da SAC
				, dbo.GetSacPazienteXmlById(@IdPazienteAttivo) AS Paziente		

				, "ns0:NotaAnamnestica".IdEsterno
				, "ns0:NotaAnamnestica".DataInserimento
				, "ns0:NotaAnamnestica".DataModifica
				, "ns0:NotaAnamnestica".DataModificaEsterno
				, "ns0:NotaAnamnestica".StatoCodice
				, dbo.GetNotaAnamnesticaStatoDesc("ns0:NotaAnamnestica".StatoCodice, NULL) AS StatoDescrizione
				, "ns0:NotaAnamnestica".AziendaErogante
				, "ns0:NotaAnamnestica".SistemaErogante
				, "ns0:NotaAnamnestica".DataNota
				, "ns0:NotaAnamnestica".DataFineValidita
				, "ns0:NotaAnamnestica".TipoCodice
				, "ns0:NotaAnamnestica".TipoDescrizione
				, "ns0:NotaAnamnestica".Contenuto
				, "ns0:NotaAnamnestica".TipoContenuto
				, "ns0:NotaAnamnestica".ContenutoHtml
				, "ns0:NotaAnamnestica".ContenutoText

				, @XmlAttributiNoteAnamnestiche AS Attributi

				, @XmlTutteLeNoteAnamnestiche  AS Note
			
			FROM store.NoteAnamnestiche AS "ns0:NotaAnamnestica"
			WHERE "ns0:NotaAnamnestica".Id = @ID
				AND "ns0:NotaAnamnestica".DataPartizione = @DataPartizione
			FOR XML AUTO, ELEMENTS, BINARY BASE64
		)
	END
	--
	-- 
	--
	RETURN @XmlNotaAnamnestica

END