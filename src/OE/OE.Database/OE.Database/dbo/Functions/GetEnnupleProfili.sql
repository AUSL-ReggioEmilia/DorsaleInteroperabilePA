

CREATE FUNCTION [dbo].[GetEnnupleProfili]
(
	  @Utente varchar(64)
	, @idSistemaRichiedente uniqueidentifier
)
RETURNS @Result TABLE (IdGruppoPrestazioni uniqueidentifier, [Not] bit NOT NULL) 
AS
BEGIN

	INSERT INTO @Result
		SELECT e.IDGruppoPrestazioni, e.[Not]
		FROM Ennuple e
		WHERE
				-- Per tutti o per un gruppo specifico
				( e.IDGruppoUtenti IS NULL
					OR e.IDGruppoUtenti IN (SELECT ID FROM [dbo].[GetGruppiOePerUtente](@Utente))
				)
					
				-- sistema richiedente
			AND (e.IDSistemaRichiedente IS NULL OR e.IDSistemaRichiedente = @idSistemaRichiedente)
						
				-- stato
			AND e.IDStato = 1
	
	RETURN 
END


