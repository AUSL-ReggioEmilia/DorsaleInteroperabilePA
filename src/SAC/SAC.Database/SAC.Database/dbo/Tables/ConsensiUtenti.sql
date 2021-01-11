CREATE TABLE [dbo].[ConsensiUtenti] (
    [Id]                   UNIQUEIDENTIFIER CONSTRAINT [DF_ConsensiUtenti_Id] DEFAULT (newid()) ROWGUIDCOL NOT NULL,
    [Utente]               VARCHAR (64)     NOT NULL,
    [Provenienza]          VARCHAR (16)     NOT NULL,
    [Lettura]              BIT              CONSTRAINT [DF_ConsensiUtenti_Lettura] DEFAULT ((0)) NOT NULL,
    [Scrittura]            BIT              CONSTRAINT [DF_ConsensiUtenti_Scrittura] DEFAULT ((0)) NOT NULL,
    [Cancellazione]        BIT              CONSTRAINT [DF_ConsensiUtenti_Cancellazione] DEFAULT ((0)) NOT NULL,
    [LivelloAttendibilita] TINYINT          CONSTRAINT [DF_ConsensiUtenti_LivelloAttendibilita] DEFAULT ((100)) NOT NULL,
    [IngressoAck]          BIT              CONSTRAINT [DF_ConsensiUtenti_AckInput] DEFAULT ((0)) NOT NULL,
    [IngressoAckUrl]       VARCHAR (255)    NULL,
    [NotificheAck]         BIT              CONSTRAINT [DF_ConsensiUtenti_AckOutput] DEFAULT ((0)) NOT NULL,
    [NotificheUrl]         VARCHAR (255)    NULL,
    [Disattivato]          TINYINT          CONSTRAINT [DF_ConsensiUtenti_Disattivato] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ConsensiUtenti] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_ConsensiUtenti_Provenienze] FOREIGN KEY ([Provenienza]) REFERENCES [dbo].[Provenienze] ([Provenienza]),
    CONSTRAINT [FK_ConsensiUtenti_Utenti] FOREIGN KEY ([Utente]) REFERENCES [dbo].[Utenti] ([Utente])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Utente]
    ON [dbo].[ConsensiUtenti]([Utente] ASC) WITH (FILLFACTOR = 95);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0=Attivo; 1=Disattivato;', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConsensiUtenti', @level2type = N'COLUMN', @level2name = N'Disattivato';

