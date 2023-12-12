SELECT * 
FROM NashvilleHousing

/*
CLEANING DATA IN SQL QUERIES(PURPOSE is to make it moore easy to read and get rid od unnecessarry data)
*/

--------------------------------------------------------
--STANDARDIZED DATE FORMAT	
SELECT SaleDate2,CONVERT(date,SaleDate) as SellingDate
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

ALTER Table NashvilleHousing
ADD SaleDate2 Date;

Update NashvilleHousing
SET SaleDate2 = CONVERT(date,SaleDate)

--------------------------------------------------------------------------
--Populate Property Address data

Select *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


Select NH1.ParcelID,NH1.PropertyAddress,NH2.ParcelID,NH2.PropertyAddress
FROM NashvilleHousing as NH1
JOIN NashvilleHousing as NH2
	ON NH1.ParcelID = NH2.ParcelID
	AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL

UPDATE NH1
SET PropertyAddress = ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
FROM NashvilleHousing as NH1
JOIN NashvilleHousing as NH2
	ON NH1.ParcelID = NH2.ParcelID
	AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL

-------------------------------------------------------------------------------------
--Breaking Out Address into individual column(Address,City,State)
SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address
FROM NashvilleHousing 

ALTER Table NashvilleHousing
ADD Address_Street nvarchar(255);

Update NashvilleHousing
SET Address_Street = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER Table NashvilleHousing
ADD Address_City nvarchar(255);

Update NashvilleHousing
SET Address_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

SELECT * FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER Table NashvilleHousing
ADD Owner_st_Address nvarchar(255);
ALTER Table NashvilleHousing
ADD Owner_City nvarchar(255);
ALTER Table NashvilleHousing
ADD Owner_state nvarchar(255);

Update NashvilleHousing
SET Owner_st_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
Update NashvilleHousing
SET Owner_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)v
Update NashvilleHousing
SET Owner_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

------------------------------------------------------------------------------------------------
--Changing Y and N with Yes and No in "Sold as Vacant"

SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
				   END

------------------------------------------------------------------------------------------------------
--Remove Duplicates
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
					 )row_num
FROM NashvilleHousing
)
SELECT *
FROM RowNumCTE WHERE row_num > 1 
ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------
--DELETE UNUSED ITEMS
SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate