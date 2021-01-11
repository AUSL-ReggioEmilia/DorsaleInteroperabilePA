


-- =============================================
-- Author:		
-- Create date: 
-- Description:	Restituisce la lista delle ennuple relative ai dati accessori
-- ModifyDate: 26/03/2019
-- By: LucaB.
-- =============================================


CREATE PROCEDURE [dbo].[UiEnnupleDatiAccessoriList]

 @GruppoUtenti as varchar(256) = NULL
,@DescrizioneDatoAccessorio as varchar(64) = NULL
,@Descrizione as varchar(256) = NULL
--,@Lunedi as bit = NULL
--,@Martedi as bit = NULL
--,@Mercoledi as bit = NULL
--,@Giovedi as bit = NULL
--,@Venerdi as bit = NULL
--,@Sabato as bit = NULL
--,@Domenica as bit = NULL
,@IDUnitaOperativa as uniqueidentifier = NULL
,@IDSistemaRichiedente as uniqueidentifier = NULL
,@CodiceRegime as varchar(16) = NULL
,@CodicePriorita as varchar(16) = NULL
,@Inverso as bit = NULL
,@IDStato as tinyint = NULL
,@Note as varchar(1024) = NULL

AS
BEGIN
SET NOCOUNT ON

SELECT EnnupleDatiAccessori.ID
      ,EnnupleDatiAccessori.DataInserimento
      ,EnnupleDatiAccessori.DataModifica
      ,EnnupleDatiAccessori.UtenteInserimento
      ,EnnupleDatiAccessori.UtenteModifica
	  ,EnnupleDatiAccessori.Note
      ,IDGruppoUtenti
      ,GruppiUtenti.Descrizione as GruppoUtenti
      --,IDGruppoPrestazioni
	  ,DatiAccessori.Codice as CodiceDatoAccessorio
      ,DatiAccessori.Etichetta as DatoAccessorioDescrizione
      ,EnnupleDatiAccessori.Descrizione
      ,OrarioInizio
      ,OrarioFine
      ,Lunedi
      ,Martedi
      ,Mercoledi
      ,Giovedi
      ,Venerdi
      ,Sabato
      ,Domenica
      ,IDUnitaOperativa
      ,UnitaOperative.Descrizione as UnitaOperativa
      ,IDSistemaRichiedente
      ,(Sistemi.CodiceAzienda + '-' + ISNULL(Sistemi.Codice, Sistemi.Descrizione)) as SistemaRichiedente 
      ,CodiceRegime
      ,Regimi.Descrizione as Regime
      ,CodicePriorita
      ,Priorita.Descrizione as Priorita
      ,[Not] as Inverso
      ,IDStato
      ,EnnupleStati.Descrizione as Stato
  FROM dbo.EnnupleDatiAccessori
					   LEFT JOIN GruppiUtenti on GruppiUtenti.ID = EnnupleDatiAccessori.IDGruppoUtenti
					   LEFT JOIN DatiAccessori on DatiAccessori.Codice = EnnupleDatiAccessori.CodiceDatoAccessorio
					   LEFT JOIN UnitaOperative on UnitaOperative.ID = IDUnitaOperativa
					   LEFT JOIN Sistemi on Sistemi.ID = IDSistemaRichiedente
					   LEFT JOIN Regimi on Regimi.Codice = CodiceRegime
					   LEFT JOIN Priorita on Priorita.Codice = CodicePriorita
					   LEFT JOIN EnnupleStati on EnnupleStati.ID = EnnupleDatiAccessori.IDStato
	
WHERE (@Descrizione IS NULL OR EnnupleDatiAccessori.Descrizione LIKE '%'+@Descrizione+'%')
 AND (@Note IS NULL OR EnnupleDatiAccessori.Note LIKE '%'+@Note+'%')
  AND (@GruppoUtenti IS NULL OR GruppiUtenti.Descrizione LIKE '%'+@GruppoUtenti+'%' OR GruppiUtenti.Descrizione IS NULL)
  -- QUANDO FILTRO PER DATO ACCESSORIO CERCO SIA NELL'ETICHETTA, DESCRIZIONE E 
  AND (@DescrizioneDatoAccessorio IS NULL 
		OR DatiAccessori.Etichetta LIKE '%'+@DescrizioneDatoAccessorio+'%' 
		OR DatiAccessori.Descrizione LIKE '%'+@DescrizioneDatoAccessorio +'%' 
		OR DatiAccessori.Codice LIKE '%'+@DescrizioneDatoAccessorio+'%'
		OR DatiAccessori.Etichetta IS NULL
		)
  --AND (@Lunedi IS NULL OR Lunedi = @Lunedi)
  --AND (@Martedi IS NULL OR Martedi = @Martedi)
  --AND (@Mercoledi IS NULL OR Mercoledi = @Mercoledi)
  --AND (@Giovedi IS NULL OR Giovedi = @Giovedi)
  --AND (@Venerdi IS NULL OR Venerdi = @Venerdi)
  --AND (@Sabato IS NULL OR Sabato = @Sabato)
  --AND (@Domenica IS NULL OR Domenica = @Domenica)
  AND (@IDUnitaOperativa IS NULL OR IDUnitaOperativa = @IDUnitaOperativa OR IDUnitaOperativa IS NULL)
  AND (@IDSistemaRichiedente IS NULL OR IDSistemaRichiedente = @IDSistemaRichiedente OR IDSistemaRichiedente IS NULL)
  AND (@CodiceRegime IS NULL OR CodiceRegime = @CodiceRegime OR CodiceRegime IS NULL)
  AND (@CodicePriorita IS NULL OR CodicePriorita = @CodicePriorita OR CodicePriorita IS NULL)
  AND (@Inverso IS NULL OR [Not] = @Inverso)
  AND (@IDStato IS NULL OR IDStato = @IDStato)

ORDER BY EnnupleDatiAccessori.Descrizione

SET NOCOUNT OFF
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[UiEnnupleDatiAccessoriList] TO [DataAccessUi]
    AS [dbo];

