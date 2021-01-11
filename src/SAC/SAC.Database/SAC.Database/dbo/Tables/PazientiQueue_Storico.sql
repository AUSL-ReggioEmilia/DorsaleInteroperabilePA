CREATE TABLE [dbo].[PazientiQueue_Storico] (
    [Id]             INT          IDENTITY (1, 1) NOT NULL,
    [DataLog]        DATETIME     CONSTRAINT [DF_PazientiQueue_Storico_DataLog] DEFAULT (getdate()) NOT NULL,
    [Utente]         VARCHAR (64) NOT NULL,
    [Operazione]     TINYINT      NOT NULL,
    [DataOperazione] DATETIME     NOT NULL,
    [IdPaziente]     VARCHAR (64) NOT NULL,
    [Paziente]       XML          NOT NULL,
    CONSTRAINT [PK_PazientiQueue_Storico] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

