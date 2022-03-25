USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[pokaż_repertuar2]    Script Date: 24.03.2022 17:51:22 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Procedura pokazuje nam repertuar we wskazanym dniu. 
W przypadku braku wyboru dnia, prcedura pokazuje dzień dzisiejszy.
Procedura korzysta z widoku zaindeksowanego. 
*/
Create or ALTER   procedure [dbo].[pokaż_repertuar2]
(@data as date = null)
as 
begin
	set @data = ISNULL(@data, getdate())
----------------------------------------
	select 
			nazwa_filmu
		   ,STRING_AGG(godzina, ',') as godziny
	from Wyświetlane_filmy WITH (NOEXPAND)
	where dzień = @data 
	group by Nazwa_filmu
end 

