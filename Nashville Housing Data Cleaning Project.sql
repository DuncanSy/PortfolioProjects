----/* Cleaning Data */----

--SELECT *
--FROM NashvilleHousingSQL..NashvilleHousing$

----/* Formatting Date */----

--SELECT SaleDate, CONVERT(Date, SaleDate)
--FROM NashvilleHousingSQL..NashvilleHousing$

--UPDATE NashvilleHousingSQL..NashvilleHousing$
--SET SaleDate = CONVERT(Date, SaleDate)

--SELECT SaleDate
--FROM NashvilleHousingSQL..NashvilleHousing$

/* ^ Does not work */

--ALTER TABLE NashvilleHousingSQL..NashvilleHousing$ 
--ADD SaleDateAdjusted Date

--UPDATE NashvilleHousingSQL..NashvilleHousing$
--SET SaleDateAdjusted = CONVERT(Date, SaleDate)

--SELECT SaleDateAdjusted
--FROM NashvilleHousingSQL..NashvilleHousing$

----/* Property Address Data */----

/* Identify NULLs */

--SELECT *
--FROM NashvilleHousingSQL..NashvilleHousing$
--WHERE PropertyAddress IS NULL

/* NULLs due to duplicate ParcelIDs */

--SELECT *
--FROM NashvilleHousingSQL..NashvilleHousing$
--ORDER BY ParcelID

--SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
--FROM NashvilleHousingSQL..NashvilleHousing$ a
--JOIN NashvilleHousingSQL..NashvilleHousing$ b
--	ON a.ParcelID = b.ParcelID
--	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL

--SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
--FROM NashvilleHousingSQL..NashvilleHousing$ a
--JOIN NashvilleHousingSQL..NashvilleHousing$ b
--	ON a.ParcelID = b.ParcelID
--	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL

--UPDATE a
--SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
--FROM NashvilleHousingSQL..NashvilleHousing$ a
--JOIN NashvilleHousingSQL..NashvilleHousing$ b
--	ON a.ParcelID = b.ParcelID
--	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL

----/* Separate PropertyAddress (Address, City, State) */----

--SELECT PropertyAddress
--FROM NashvilleHousingSQL..NashvilleHousing$

--SELECT
--SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS StreetAddress
--, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) AS CityTown
--FROM NashvilleHousingSQL..NashvilleHousing$

/* Street Address Column */

--ALTER TABLE NashvilleHousingSQL..NashvilleHousing$ 
--ADD StreetAddress nvarchar(255)

--UPDATE NashvilleHousingSQL..NashvilleHousing$
--SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--SELECT StreetAddress
--FROM NashvilleHousingSQL..NashvilleHousing$

/* City Town Column */

--ALTER TABLE NashvilleHousingSQL..NashvilleHousing$ 
--ADD CityTown nvarchar(255)

--UPDATE NashvilleHousingSQL..NashvilleHousing$
--SET CityTown = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))

--SELECT CityTown
--FROM NashvilleHousingSQL..NashvilleHousing$

/* Owner Address */

--SELECT OwnerAddress
--FROM NashvilleHousingSQL..NashvilleHousing$

--SELECT
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerStreetAddress
--, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCityTown
--, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
--FROM NashvilleHousingSQL..NashvilleHousing$

--ALTER TABLE NashvilleHousingSQL..NashvilleHousing$ 
--ADD OwnerStreetAddress nvarchar(255)

--ALTER TABLE NashvilleHousingSQL..NashvilleHousing$ 
--ADD OwnerCityTown nvarchar(255)

--ALTER TABLE NashvilleHousingSQL..NashvilleHousing$ 
--ADD OwnerState nvarchar(255)

--UPDATE NashvilleHousingSQL..NashvilleHousing$
--SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--UPDATE NashvilleHousingSQL..NashvilleHousing$
--SET OwnerCityTown = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--UPDATE NashvilleHousingSQL..NashvilleHousing$
--SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--SELECT OwnerStreetAddress, OwnerCityTown, OwnerState
--FROM NashvilleHousingSQL..NashvilleHousing$

----/* Change values "Sold as Vacant" */----

--SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
--FROM NashvilleHousingSQL..NashvilleHousing$
--GROUP BY SoldAsVacant

--SELECT SoldAsVacant
--, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
--	WHEN SoldAsVacant = 'N' THEN 'No'
--	ELSE SoldAsVacant
--	END
--FROM NashvilleHousingSQL..NashvilleHousing$
--WHERE SoldAsVacant = 'Y'

--UPDATE NashvilleHousingSQL..NashvilleHousing$
--SET SoldAsVacant = 
--CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
--	WHEN SoldAsVacant = 'N' THEN 'No'
--	ELSE SoldAsVacant
--	END

----/* Remove Duplicates */----

--WITH RowNumCTE AS(
--SELECT *,
--	ROW_NUMBER() Over (
--	PARTITION BY ParcelID, 
--	PropertyAddress,
--	SalePrice,
--	SaleDate,
--	LegalReference
--	ORDER BY UniqueID
--	) row_num
--FROM NashvilleHousingSQL..NashvilleHousing$
--)
--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

-- Check --

--WITH RowNumCTE AS(
--SELECT *,
--	ROW_NUMBER() Over (
--	PARTITION BY ParcelID, 
--	PropertyAddress,
--	SalePrice,
--	SaleDate,
--	LegalReference
--	ORDER BY UniqueID
--	) row_num
--FROM NashvilleHousingSQL..NashvilleHousing$
--)
--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1

----/* Delete Unused Columns */----

--ALTER TABLE NashvilleHousingSQL..NashvilleHousing$
--DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

--SELECT *
--FROM NashvilleHousingSQL..NashvilleHousing$