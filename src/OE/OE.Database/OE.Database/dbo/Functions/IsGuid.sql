
CREATE FUNCTION [dbo].[IsGuid]            
(            
    @strGUID varchar(64)           
)            
RETURNS BIT
AS            
BEGIN            
	DECLARE @IsGUID BIT
	
    SET @strGUID = REPLACE(REPLACE(@strGUID, '{', ''), '}', '')
    SET @IsGUID = 
		CASE WHEN @strGUID like             
			'[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]-[0-9A-F][0-9A-F][0-9A-F][0-9A-F]-[0-9A-F][0-9A-F][0-9A-F][0-9A-F]-[0-9A-F][0-9A-F][0-9A-F][0-9A-F]-[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]'
			THEN 1
			ELSE 0
		END   
    		         
    RETURN @IsGUID

END            
