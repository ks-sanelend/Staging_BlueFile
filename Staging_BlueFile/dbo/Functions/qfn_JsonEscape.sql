CREATE FUNCTION [dbo].[qfn_JsonEscape](@value nvarchar(max) )
returns nvarchar(max)
as begin
 
 if (@value is null) return 'null'
 if (TRY_PARSE( @value as float) is not null)  return '"'+@value+'"' --return @value

 set @value=replace(@value,'\','\\')
 set @value=replace(@value,'"','\"')

 return '"'+@value+'"'
end
