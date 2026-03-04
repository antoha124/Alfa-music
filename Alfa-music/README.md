# MusicApp — Лабораторная №2

## Архитектура

Выбрал MVVM. Основная причина — ViewModel ничего не знает про UIKit, значит её можно тестировать отдельно, просто подсунув мок-сервис. MVC не подошёл, потому что логика быстро уезжает в контроллер. VIPER показался избыточным для трёх экранов — слишком много файлов на каждый модуль.


## Модули

Три экрана: Auth, Catalog, TrackDetail.


## Auth

Стартовый экран, входных данных нет. При успешном входе отдаёт `UserSession` и открывает Catalog.

Состояния: `initial` → пустая форма, `loading` → крутилка пока идёт запрос, `content` → вход прошёл, `error(String)` → показываем текст ошибки.

Сценарии:
1. Ввёл email и пароль, нажал войти → `didTapLogin` → сервис логинит → `loading` → `content` → переход в Catalog
2. Можно же войти как гость → `didTapGuestLogin` → `loginAsGuest` → переход в Catalog
3. Неверные данные → рендер `error("Неверный email или пароль")`


## Catalog

Входных данных нет, открывается после успешной авторизации. При выборе альбома отдаёт `albumId` и открывает TrackDetail.

Состояния: `initial`, `loading`, `content([Album])`, `error(String)`.

Сценарии:
1. Открылся экран → `didLoad` → `fetchAlbums` → `loading` → `content`
2. Ввёл поисковый запрос → `didSearch(query:)` → `search` → `content`
3. Ошибка загрузки → `error` → нажал Retry → `didTapRetry` → повторная загрузка
4. Нажал на альбом → `didSelectAlbum(id:)` → переход в TrackDetail


## TrackDetail

Получает `trackId` и `albumId`, наружу ничего не отдаёт.

Состояния: `initial`, `loading`, `content(TrackDetailContent)` — внутри флаги `isPlaying`, `isLiked`, `hasPrevious`, `hasNext`, `error(String)`.

Сценарии:
1. Открылся экран → `didLoad` → грузим трек и весь список треков альбома → рендер `content`
2. Нажал Play/Pause → `didTapPlay` → меняем `isPlaying`
3. Нажал Next/Previous → ViewModel берёт следующий/предыдущий трек из кэша по `albumId` → рендер нового `content`
4. Нажал Like → `didTapLike` → меняем `isLiked`

