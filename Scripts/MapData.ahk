#Requires AutoHotkey v2.0

global CategoryStartPages := Map(
    "Beginner", 1,
    "Intermediate", 6,
    "Advanced", 11,
    "Expert", 15
)

global MapData := Map(

    "Monkey Meadow", {
        category: "Beginner",
        page: 1,
        pattern: "|<>*159$22.zzU3zw0Dzw0zzs3zk0Dk00zU03y00Dw00zkk3zzzzzzzzzzzzzzkTzs1kDU3000Q000k003000Q001k007000Q011k0Tz3zzzzzzzzwM008"
    },

    "Intermediate Map", {
        category: "Intermediate",
        page: 6,
        pattern: "|<>YOUR_INTERMEDIATE_MAP_PATTERN"
    },


    "Advanced Map", {
        category: "Advanced",
        page: 0,
        pattern: "|<>YOUR_ADVANCED_MAP_PATTERN"
    },


    "Expert Map", {
        category: "Expert",
        page: 0,
        pattern: "|<>YOUR_EXPERT_MAP_PATTERN"
    }
)