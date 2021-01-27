import pandas as pd


data = pd.read_csv("home_eda_with_listinginfo.csv")

# Clean bds null
data = data[pd.notnull(data["bds"])]
# print(data.shape[0])

# Clean ba null
data = data[pd.notnull(data["ba"])]
# print(data.shape[0])

# Clean sqft null
data = data[pd.notnull(data["sqft"])]
# print(data.shape[0])

# Filter sold_year to 2020
data = data[data["sold_year"] == 2020]
# print(data.shape[0])

# Drop sold_month, sold_day
data = data.drop(["sold_month"], axis=1)
data = data.drop(["sold_day"], axis=1)

# Turn type into dummy variables
dummy = pd.get_dummies(data["type"])
# print(dummy)
# Combine and drop type
data = pd.concat([data, dummy], axis=1)
# print(data.head())
data = data.drop(["type"], axis=1)
# print(data.head())

# Clean year_built null
data = data[pd.notnull(data["year_built"])]
# print(data.shape[0])
# Turn year_built into building_age
data["year_built"] = pd.to_numeric(data["year_built"])
building_age = 2020 - data["year_built"]
data["building_age"] = building_age
data = data.drop(["year_built"], axis=1)
# print(data["building_age"])

# Drop pets and laundry
data = data.drop(["pets"], axis=1)
data = data.drop(["laundry"], axis=1)
# print(data.shape[0])

# Reset index
data = data.reset_index(drop=True)

# Convert parking column
# list of options
parking_option_list = data["parking"].tolist()
output = set()
for comma_string in parking_option_list:
    row_list = comma_string.split(", ")
    for option in row_list:
        output.add(option)

# Create multi_dummy columns
for option in output:
    data[option] = [0] * data.shape[0]
    for i in range(data.shape[0]):
        row_list = data.loc[i, "parking"].split(", ")
        if option in row_list:
            data.loc[i, option] = 1

# drop parking column
data = data.drop(["parking"], axis=1)


# data.to_csv(r"C:\Users\User\Desktop\Columbia\Operation Consulting\AssetCast\data\data_for_modeling.csv")
data.to_csv(r"C:\Users\User\Desktop\Columbia\Operation Consulting\AssetCast\data\data_for_modeling_v2.csv")