CREATE TABLE [dbo].[DizionariLhaNazioni] (
    [CodiceInternoNazione]    NVARCHAR (3)  NOT NULL,
    [DescrizioneNazione]      NVARCHAR (40) NOT NULL,
    [IstatNazione]            VARCHAR (3)   NULL,
    [DataInizioValidita]      DATETIME      NULL,
    [DataFineValidita]        DATETIME      NULL,
    [FlagPaeseUE]             NVARCHAR (1)  NOT NULL,
    [TimestampUltimaModifica] DATETIME      NOT NULL,
    CONSTRAINT [PK_DizionariLhaNazioni] PRIMARY KEY CLUSTERED ([CodiceInternoNazione] ASC) WITH (FILLFACTOR = 95)
);


GO
GRANT DELETE
    ON OBJECT::[dbo].[DizionariLhaNazioni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[DizionariLhaNazioni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[DizionariLhaNazioni] TO [DataAccessSSIS]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[DizionariLhaNazioni] TO [DataAccessSSIS]
    AS [dbo];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'S=paese UE; N=paese extra UE;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DizionariLhaNazioni', @level2type = N'COLUMN', @level2name = N'FlagPaeseUE';

