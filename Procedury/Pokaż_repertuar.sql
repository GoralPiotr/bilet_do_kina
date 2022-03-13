USE [bilet_kinowy]
GO
/****** Object:  StoredProcedure [dbo].[pokaż_repertuar2]    Script Date: 13.03.2022 17:27:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
Procedura pokazuje nam repertuar we wskazanym dniu.
Procedura korzysta z widoku zaindeksowanego. 
*/
ALTER   procedure [dbo].[pokaż_repertuar2]
(@data as date = null)
as 
begin
	set @data = ISNULL(@data, getdate())
	--select Nazwa_filmu,godzina from Wyświetlane_filmy WITH (NOEXPAND)
	--where dzień = @data
	select 
			nazwa_filmu
		   ,STRING_AGG(godzina, ',') as godziny
	from Wyświetlane_filmy WITH (NOEXPAND)
	where dzień = @data 
	group by Nazwa_filmu
end 

