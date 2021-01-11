﻿CREATE TABLE [dbo].[DatabaseLog] (
    [DatabaseLogID] INT       IDENTITY (1, 1) NOT NULL,
    [PostTime]      DATETIME  NOT NULL,
    [DatabaseUser]  [sysname] NOT NULL,
    [LoginName]     [sysname] NOT NULL,
    [Event]         [sysname] NOT NULL,
    [Schema]        [sysname] NULL,
    [Object]        [sysname] NULL,
    [XmlEvent]      XML       NOT NULL,
    CONSTRAINT [PK_DatabaseLog_DatabaseLogID] PRIMARY KEY NONCLUSTERED ([DatabaseLogID] ASC) WITH (FILLFACTOR = 95)
);

