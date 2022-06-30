
--CLEANING DATA

------------------------------------------------------------------------
 Select *
 From Housing_Data..Nashville_Housing


------------------------------Change SaleDate Format--------------------------------
 Select SaleDate
 From Housing_Data..Nashville_Housing


-- Column called Sale_Date_Converted that has the data type set to date
 Alter Table Housing_Data..Nashville_Housing
 Add Sale_Date_Converted date;


-- Adds the date data from the SaleDate Column but not the time data
 Update Housing_Data..Nashville_Housing
 Set Sale_Date_Converted = CONVERT (date,SaleDate)


-- Deletes the SaleDate column leaving only the Sale_Date_Converted column
ALTER TABLE Housing_Data..Nashville_Housing
DROP COLUMN SaleDate;


--Shows the Sale_Date_Converted 
Select Sale_Date_Converted
From Housing_Data..Nashville_Housing


---------------------------Removes Null Values of PropertyAddress and replaces them with the correct address-------------------------------------------


--Shows all the null values for PropertyAddress
select PropertyAddress
from Housing_Data..Nashville_Housing
where PropertyAddress is null
order by ParcelID


--Creates two PropertyAddress columns one that has only null vales (a) and another with the same ParcelID with the corsponding address (b).  
--Then makes a column that looks to see if (a) is null and if it is it replaces it with (b) leaving a column with null values replaced by the correct address (c). 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull (a.PropertyAddress, b.PropertyAddress)
from Housing_Data..Nashville_Housing a
Join Housing_Data..Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null


--updates the PropertyAddress column to column (c) 
update a
set PropertyAddress = isnull (a.PropertyAddress, b.PropertyAddress)
from Housing_Data..Nashville_Housing a
Join Housing_Data..Nashville_Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
Where a.PropertyAddress is null


--------------------------------------------Breaks out address into Individual columns (Addresss, City, State)---------------------------------------------------------------------------


--Shows the PropertyAddress column
select PropertyAddress
from Housing_Data..Nashville_Housing


--Creates a column with only the charcters that happen before the "," which dilinates the address from the city.
--Creates a column with only the charcters that happen after  the "," which dilinates the address from the city.
select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, 100) as City 
from Housing_Data..Nashville_Housing

 
--Adds column Property_Split_Address
 Alter Table Housing_Data..Nashville_Housing
 Add Property_Split_Address nvarchar(255);
 

--Updates column Property_Split_Address with the rows from the "Address" column created in the select statement above.
 Update Housing_Data..Nashville_Housing
 Set Property_Split_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


--Adds column Property_Split_City
 Alter Table Housing_Data..Nashville_Housing
 Add Property_Split_City nvarchar(255);
 

--Updates column Property_Split_City with the rows from the "City" column created in the select statement above.
 Update Housing_Data..Nashville_Housing
 Set Property_Split_City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, 100)


--Shows the new columns as well as the one that they were derived from
 select Property_Split_Address, Property_Split_City,  PropertyAddress
 from Housing_Data..Nashville_Housing


--Creates three new columns the Address, City, or State part as delinitated by ","
 Select 
 PARSENAME(replace(OwnerAddress, ',','.'), 3) as Address,
  PARSENAME(replace(OwnerAddress, ',','.'), 2) as City,
   PARSENAME(replace(OwnerAddress, ',','.'), 1) as State
from Housing_Data..Nashville_Housing
 
--Adds column Owner_Split_Addres
 Alter Table Housing_Data..Nashville_Housing
 Add Owner_Split_Address nvarchar(255);
 

--Updates column Owner_Split_Addres with the rows from the "Address" column created in the select statement above.
 Update Housing_Data..Nashville_Housing
 Set Owner_Split_Address =  PARSENAME(replace(OwnerAddress, ',','.'), 3)


--Adds column Owner_Split_City
 Alter Table Housing_Data..Nashville_Housing
 Add Owner_Split_City nvarchar(255);
 

--Updates column Owner_Split_City with the rows from the "City" column created in the select statement above.
 Update Housing_Data..Nashville_Housing
 Set Owner_Split_City = PARSENAME(replace(OwnerAddress, ',','.'), 2)


--Adds column Owner_Split_State
 Alter Table Housing_Data..Nashville_Housing
 Add Owner_Split_State nvarchar(255);
 

 --Updates column Owner_Split_State with the rows from the "State" column created in the select statement above.
 Update Housing_Data..Nashville_Housing
 Set Owner_Split_State = PARSENAME(replace(OwnerAddress, ',','.'), 1)


 ------------------------Changing Y and N to Yes and No in SoldAsVacant--------------------------------------------


--Shows and counts the distinct vales in SoldAsVacant
select distinct SoldAsVacant, COUNT(SoldAsVacant)
from Housing_Data..Nashville_Housing
group by SoldAsVacant


--A case statement that changes all 'Y' to 'Yes' and all 'N' to 'No'
select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End
from Housing_Data..Nashville_Housing


--Updates the SoldAsVacant column using the above case statement to 
Update Housing_Data..Nashville_Housing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   End


--------------------------------Delets unused columns ------------------------------------------

--Deletes the PropertyAddress, and the OwnerAddress columns that we rendered useless by broke the info within them down into more usefull columns
Alter Table Housing_Data..Nashville_Housing
Drop Column PropertyAddress, OwnerAddress