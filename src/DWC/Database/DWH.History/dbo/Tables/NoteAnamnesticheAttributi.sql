CREATE TABLE [dbo].[NoteAnamnesticheAttributi] (
    [IdNoteAnamnesticheBase] UNIQUEIDENTIFIER NOT NULL,
    [Nome]                   VARCHAR (64)     NOT NULL,
    [Valore]                 SQL_VARIANT      NULL,
    [DataPartizione]         SMALLDATETIME    NOT NULL,
    CONSTRAINT [PK_NoteAnamnesticheAttributi] PRIMARY KEY CLUSTERED ([DataPartizione] ASC, [IdNoteAnamnesticheBase] ASC, [Nome] ASC) WITH (FILLFACTOR = 70),
    CONSTRAINT [CK_NoteAnamnesticheAttributi_DataPartizione] CHECK ([DataPartizione]<CONVERT([smalldatetime],'20070101',(0))),
    CONSTRAINT [FK_NoteAnamnesticheAttributi_NoteAnamnesticheBase] FOREIGN KEY ([DataPartizione], [IdNoteAnamnesticheBase]) REFERENCES [dbo].[NoteAnamnesticheBase] ([DataPartizione], [Id]) ON DELETE CASCADE NOT FOR REPLICATION
);


GO
ALTER TABLE [dbo].[NoteAnamnesticheAttributi] NOCHECK CONSTRAINT [FK_NoteAnamnesticheAttributi_NoteAnamnesticheBase];




GO
ALTER TABLE [dbo].[NoteAnamnesticheAttributi] NOCHECK CONSTRAINT [FK_NoteAnamnesticheAttributi_NoteAnamnesticheBase];




GO
ALTER TABLE [dbo].[NoteAnamnesticheAttributi] NOCHECK CONSTRAINT [FK_NoteAnamnesticheAttributi_NoteAnamnesticheBase];


GO
CREATE UNIQUE NONCLUSTERED INDEX [IXU_IdNotaAnamnestica_Nome]
    ON [dbo].[NoteAnamnesticheAttributi]([IdNoteAnamnesticheBase] ASC, [Nome] ASC) WITH (FILLFACTOR = 70);



