EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Output parameter for the stored procedure uspLogError. Contains the ErrorLogID value corresponding to the row inserted by uspLogError in the ErrorLog table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'LogError', @level2type = N'PARAMETER', @level2name = N'@ErrorLogID';

