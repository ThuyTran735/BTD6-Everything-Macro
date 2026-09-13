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
        pattern: "|<>*148$39.070D0Q01s1k3U0D0C0Q03s1k3U1z0C0Q0zs1k3Uzz0C0Q7zzzzzUzzzzzzzzzzzzzzzzvzzzzVU00zzw0E207zm3000zzzk004"
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