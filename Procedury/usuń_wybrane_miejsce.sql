USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[usuń_wybrane_miejsce]    Script Date: 21.06.2022 18:22:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Za sprawą procedury użytkownik może odznaczyć uprzednio wybrane miejsce.
Procedura usuwa miejsca danej sesji
*/
ALTER   proc [dbo].[usuń_wybrane_miejsce]
@miejsce1 as smallint
as
begin try
begin tran
	declare @id_sesji as smallint 
	set @id_sesji = (select @@spid)
----------------------------------------
if @miejsce1 not in  (select id_miejsca 
						from tymczasowa_rezerwacja
					   where id_sesji = @id_sesji)
		begin 
			raiserror ('nie ma takiego miejsca',11,1)
		end
else
		begin
			delete from tymczasowa_rezerwacja
				  where id_miejsca = @miejsce1
				    and id_sesji = @id_sesji
		end
commit
----------------------------------------
end try
begin catch
	rollback
	print 'Nie skasowałeś wybranego miejsca'
	--;throw
end catch