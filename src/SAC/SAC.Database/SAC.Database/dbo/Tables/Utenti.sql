CREATE TABLE [dbo].[Utenti] (
    [Utente]            VARCHAR (64)  NOT NULL,
    [Descrizione]       VARCHAR (128) NULL,
    [Dipartimentale]    VARCHAR (128) NULL,
    [EmailResponsabile] VARCHAR (128) NULL,
    [Disattivato]       TINYINT       CONSTRAINT [DF_Utenti_Disattivato] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_Utenti] PRIMARY KEY CLUSTERED ([Utente] ASC) WITH (FILLFACTOR = 95)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Attivo; 1=Disattivato;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Utenti', @level2type = N'COLUMN', @level2name = N'Disattivato';

