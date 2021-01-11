﻿
CREATE PROCEDURE [dbo].[LogError] 
	@ErrorLogID [int] = 0 OUTPUT 
AS                               
BEGIN
	SET NOCOUNT ON;
	SET @ErrorLogID = 0;
	BEGIN TRY
		IF ERROR_NUMBER() IS NULL
			RETURN;
			
		IF XACT_STATE() = -1
		BEGIN
			PRINT 'Cannot log error since the current transaction is in an uncommittable state. ' 
				+ 'Rollback the transaction before executing uspLogError in order to successfully log error information.';
			RETURN;
		END
			
		INSERT [dbo].[ErrorLog] 
			(
			[UserName], 
			[ErrorNumber], 
			[ErrorSeverity], 
			[ErrorState], 
			[ErrorProcedure], 
			[ErrorLine], 
			[ErrorMessage]
			) 
		VALUES 
			(
			CONVERT(sysname, CURRENT_USER), 
			ERROR_NUMBER(),
			ERROR_SEVERITY(),
			ERROR_STATE(),
			ERROR_PROCEDURE(),
			ERROR_LINE(),
			ERROR_MESSAGE()
			);
			
		SET @ErrorLogID = @@IDENTITY;
	END TRY
	BEGIN CATCH
		PRINT 'An error occurred in stored procedure uspLogError: ';
		EXECUTE [dbo].[PrintError];
		RETURN -1;
	END CATCH
END;



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Logs error information in the ErrorLog table about the error that caused execution to jump to the CATCH block of a TRY...CATCH construct. Should be executed from within the scope of a CATCH block otherwise it will return without inserting error information.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'PROCEDURE', @level1name = N'LogError';

