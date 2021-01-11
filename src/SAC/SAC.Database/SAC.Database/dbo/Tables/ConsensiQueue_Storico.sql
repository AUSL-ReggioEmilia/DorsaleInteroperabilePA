CREATE TABLE [dbo].[ConsensiQueue_Storico] (
    [Id]             INT          IDENTITY (1, 1) NOT NULL,
    [DataLog]        DATETIME     CONSTRAINT [DF_ConsensiQueue_Storico_DataLog] DEFAULT (getdate()) NOT NULL,
    [Utente]         VARCHAR (64) NOT NULL,
    [Operazione]     TINYINT      NOT NULL,
    [DataOperazione] DATETIME     NOT NULL,
    [IdConsenso]     VARCHAR (64) NOT NULL,
    [Consenso]       XML          NOT NULL,
    CONSTRAINT [PK_ConsensiQueue_Storico] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95)
);

