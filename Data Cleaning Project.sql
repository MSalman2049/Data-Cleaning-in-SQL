--Cleaning Data in SQL

Select *
from PortfolioProjectSQL..NashvilleHousing

--Standardize Date Format

Select SaleDate, Convert(Date,SaleDate)
From PortfolioProjectSQL..NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted
From PortfolioProjectSQL..NashvilleHousing

-- Populate Property Address Data

Select *
From PortfolioProjectSQL..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjectSQL..NashvilleHousing a
JOIN PortfolioProjectSQL..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProjectSQL..NashvilleHousing a
JOIN PortfolioProjectSQL..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Breaking out Address into individual Columns (Adress, City, State)

Select PropertyAddress
From PortfolioProjectSQL..NashvilleHousing

Select 
SUBSTRING (PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address
,SUBSTRING (PropertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From PortfolioProjectSQL..NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING (PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress, Charindex(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select PropertyAddress, PropertySplitAddress, PropertySplitCity
From PortfolioProjectSQL..NashvilleHousing

-- Using a different method to complete above task

Select OwnerAddress
From PortfolioProjectSQL..NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProjectSQL..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfolioProjectSQL..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select distinct(SoldAsVacant), Count(soldasVacant)
From PortfolioProjectSQL..NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End
from PortfolioProjectSQL..NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	End

-- Removing Duplicates

With RowNumCTE AS(
select *, 
	ROW_NUMBER() OVER(
	Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID) row_num

From PortfolioProjectSQL..NashvilleHousing
--Order by ParcelID)
)
select * 
from RowNumCTE
Where row_num >1
Order by PropertyAddress

-- Delete Unused Columns

Select *
From PortfolioProjectSQL..NashvilleHousing

Alter Table PortfolioProjectSQL..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProjectSQL..NashvilleHousing
Drop Column SaleDate