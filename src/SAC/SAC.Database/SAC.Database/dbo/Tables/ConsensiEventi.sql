CREATE TABLE [dbo].[ConsensiEventi] (
    [Id]             UNIQUEIDENTIFIER CONSTRAINT [DF_ConsensiEventi_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [DataOperazione] DATETIME         CONSTRAINT [DF_ConsensiEventi_DataOperazione] DEFAULT (getdate()) NOT NULL,
    [Operazione]     TINYINT          NOT NULL,
    [Codice]         INT              CONSTRAINT [DF_ConsensiEventi_Codice] DEFAULT ((0)) NOT NULL,
    [Oggetto]        VARCHAR (64)     NOT NULL,
    [Utente]         VARCHAR (64)     NOT NULL,
    [Messaggio]      VARCHAR (1024)   NOT NULL,
    CONSTRAINT [PK_ConsensiEventi] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_ConsensiEventi_EventiOperazione] FOREIGN KEY ([Operazione]) REFERENCES [dbo].[EventiOperazione] ([Id]) NOT FOR REPLICATION
);


GO
CREATE CLUSTERED INDEX [IX_DataOperazione]
    ON [dbo].[ConsensiEventi]([DataOperazione] ASC) WITH (FILLFACTOR = 95);

