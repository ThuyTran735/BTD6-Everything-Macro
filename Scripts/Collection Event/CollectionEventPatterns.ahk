#Requires AutoHotkey v2.0

; Add another event name with an array of its badge captures below.
; Put alternate appearances in the same array, then reload the macro.
; Keep each captured FindText string exactly as supplied.
global CollectionEventBadgePatterns := Map(
    "Halloween", [
        "|<>*133$63.wQDy7V0zzU4TXzVy00zy0nsTwTsD5zs7D473zXsDzkMMU0HAQ1zz7D406PU00Dsnxkknw000TbzjD700000wTznU000001kzz000000077zs0000000NwT00000001S3s00000007U000000DU0k0000003y040000000Ts000000007zU0007y000zw0003zw007zk001zzk00ty000Tzz00CDs003zzw01kz000zyTk0C7s007zVz01kzU01zw7s0C3w00Dz0TU1kTU01zs3w0C3w00Dz0Dk1kTk03zs1y0C1y00Tz0Dk1kDk03zs0z0D1y00Tz07s1sDk03zs0z0D1z00Tz07w1s7103zs0TU70UM0Tz03w0s0703zs0TU700s0TzU3w0k0301zw0Tk000s0DzU1s000D600000000nsQ0000000TzU",
        "|<HalloweenSettled>*133$63.yQDz010vz06DVzky00zy0nwTwDs77zs7DXTXzVsDzUQMU8TAC1zy37Y02Nk00Tstwk0Hy000Tbzj77s0000wTzvs000001lzzU00000077zw0000000MzTU0000001D3w00000003UDU00007U0s0000001y060000000Ts0U0000003zU0003w000zy0001zs007zk000zzk00ty000Dzz007Ds003zzw00kz000Tzzk0C7w007zlz01kTU00zw7s0C3w00DzUTU1kTU01zw3w0C3y00Dz0Dk1sDk01zs1y0D1y00Dz07s1sDk01zs0z0D1y00Dz07s1sDs01zs0zU71z00Dz03w0s7k01zw0TU70k80DzU3w0s0301zw0TU7U0M0DzU3y0s0301zw0Dk000M0DzU1y000761zU00000FsM0000000DTU",
        ; The original capture's inner area avoids its varying outer border.
        "|<HalloweenCore>*133$55.6804n70Tzj406PU00Dzr33Dk001zvnlk0000DznU000001zw0000000zy0000000QT00000008DU00000000000003s00000003y00000001zU0000001zs007y000zw00Dzk00Tz00Tzw00CTU0Tzz00CDs0Dzzk073w0Dzbw03Vy07zVz01kzU7zkTU0sDk3zk7s0Q7s1zs3w0C3w0zw0z071z0zy0TU3UTUTz0Dk1kDkDzU3w0w7s7zk1y0S3w3zs0z0D1y1zw0Tk7UQ0zy07s1k80Tz03w0s00DzU1y0Q007zs0z0A02"
    ]
)

; The scanner accepts all configured events through the same combined pattern.
global CollectionEventBonusPattern := BuildCollectionEventBonusPattern(CollectionEventBadgePatterns)

BuildCollectionEventBonusPattern(eventPatterns) {
    combinedPattern := ""
    for eventName, captures in eventPatterns {
        for capture in captures
            combinedPattern .= capture
    }
    return combinedPattern
}
