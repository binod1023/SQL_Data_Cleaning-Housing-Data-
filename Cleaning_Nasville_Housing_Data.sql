--Cleaning Data by using SQL
--Standardize date format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Housing_Nasville

UPDATE Housing_Nasville
SET SaleDate =CONVERT(Date, SaleDate)

--Above query may not work, so use below 
ALTER TABLE Housing_Nasville
Add SaleDateConverted Date;

Update Housing_Nasville
Set SaleDateConverted = CONVERT(Date, SaleDate)

--Check for update
SELECT *
FROM Housing_Nasville

--Populate Property Address Data
SELECT *
FROM Housing_Nasville
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- if ParcelID are identical and UniqueID are different, then replace the null PropertyAddress with given PorpertyAddress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing_Nasville a
JOIN Housing_Nasville b
	on a.ParcelID =b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--Update the PropertyAddress where it is Null 
UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing_Nasville a
JOIN Housing_Nasville b
	on a.ParcelID =b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

-- Breaking out Address into individual Columns( Address, City, State)
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM Housing_Nasville

ALTER TABLE Housing_Nasville
ADD Prop_splited_address Nvarchar(255);

ALTER TABLE Housing_Nasville
ADD Prop_splited_city Nvarchar(25);

UPDATE Housing_Nasville
Set Prop_splited_address=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

UPDATE Housing_Nasville
SET Prop_split_city=Substring(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress))

--Parsing Owner Address
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Housing_Nasville

ALTER TABLE Housing_Nasville
Add owner_splitted_address Nvarchar(255)

UPDATE Housing_Nasville
Set owner_splitted_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Housing_Nasville
Add owner_splitted_city Nvarchar(255)

UPDATE Housing_Nasville
Set owner_splitted_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Housing_Nasville
Add owner_splitted_state Nvarchar(255)

UPDATE Housing_Nasville
Set owner_splitted_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT SoldAsVacant,
CASE When SoldAsVacant='Y' THEN 'YES'
	When SoldAsVacant ='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Housing_Nasville

UPDATE Housing_Nasville
SET SoldAsVacant = Case When SoldAsVacant='Y' THEN 'Yes'
	WHEN SoldAsVacant ='N' THEN 'Yes'
	ELSE SoldAsVacant
	END

--cheking the updates
SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM Housing_Nasville
GROUP BY SoldAsVacant
ORDER BY 2

--Remove Duplicate

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM Housing_Nasville
)
SELECT*
FROM RowNumCTE
WHERE row_num > 1
Order by PropertyAddress

--drop Unused columns and wrongly created columns
ALTER TABLE Housing_Nasville
DROP COLUMN PropertyAddress, OwnerAddress, PropertySplitAddress, PropertySplitCity, Prop_split_address, Prop_split_city

--Rename Columns with user friendly column names
select*
FROM Housing_Nasville

sp_rename 'Housing_Nasville.Prop_splited_address','PropertySplitAddress','Column';

sp_rename 'Housing_Nasville.Prop_splited_city','PropertySplitCity','Column';

sp_rename 'Housing_Nasville.owner_splitted_address','OwnerSplitAddress','Column';

sp_rename 'Housing_Nasville.owner_splitted_city','OwnerSplitCity','Column';

sp_rename 'Housing_Nasville.owner_splitted_state','OwnerSplitState','Column';
