
# MusicApp

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


## Данные для входа

| Поле     | Значение        |
|----------|-----------------|
| Email    | `user@alfa.ru`  |
| Пароль   | `music123`      |

Также можно нажать **«Войти как гость»** — авторизация пройдёт без ввода данных.

---

## Что происходит при успешном входе

После успешной авторизации открывается экран-заглушка каталога (`CatalogViewController`):

- Отображается приветствие с именем пользователя из сессии.
- Подпись: «Каталог альбомов (в разработке)».

При неверных данных — под кнопкой появляется красный текст ошибки «Неверный email или пароль».

---

- **Сделан доп**
ошибки под полями в реальном времени (email-формат, длина пароля)


## Скриншоты

![Экран авторизации](https://disk.yandex.ru/i/p3Ngm038qyNGKw)
![Ошибка валидации](https://disk.yandex.ru/i/-ZltUfO0UN2CRw)
![Экран каталога](https://disk.yandex.ru/i/Cna0aWNFwdrrcA)
![Экран каталога](https://disk.yandex.ru/i/9uoHpdg9q824Tg)
