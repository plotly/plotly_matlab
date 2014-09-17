function converted = convertDate(date)
   converted = (date - datenum(1970,0,0))*1000*60*60*(23 + 56/60);
end