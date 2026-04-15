# MusicApp


### Что сделал в ЛР6 (кратко)

- Сделал дизайн-систему в папке `DesignSystem`.
- Вынес токены: цвета, отступы, радиусы, типографику.
- Сделал компоненты: `DSButton`, `DSFormTextField`, `DSStateContainerView`.
- Применил это на двух экранах: `Auth` и `Catalog`.
- Состояния `loading / empty / error` в каталоге показывает `DSStateContainerView`.
- Из допов сделал: **D2** — иконки (`DSIcon`)


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

Состояния: `initial`, `loading`, `content([AlbumCellViewModel])`, `empty`, `error(String)`.

**Что происходит по tap:**
- Tap по альбому → `CatalogViewModel.didSelectAlbum` → координатор `showTracks(albumId:)` → открывается `TrackDetailViewController` (Со списком треков).

**Треки чуть позже добавлю на сервак, пока просто так добавил)**

**Переиспользуемые компоненты (reuse):**
- `AlbumCell` — ячейка таблицы, настраивается только из `AlbumCellViewModel`.
- `CatalogListManager` — отдельная сущность для `UITableViewDataSource/Delegate/Prefetch`, VC не превращается в комбайн.

**Доп**
- Картинки: `ImageLoader` + `NSCache`, отмена загрузки в `prepareForReuse`.
- UI-пагинация: при приближении к концу списка list manager вызывает `didReachListEnd()` → `viewModel.didLoadMore()`.

### Сетевая загрузка (Лаба 4)

**API:** Alfa ITMO Echo API  
**Endpoint:** `https://alfaitmo.ru/server/echo/408740/albums`

**Ответ сервера (примерная структура):**
```json
[
  {
    "id": "1",
    "collectionName": "Dark Side of the Moon",
    "artistName": "Pink Floyd",
    "releaseYear": 1973,
    "artworkUrl100": "https://example.com/image.jpg"
  },
  {
    "id": "2",
    "collectionName": "Abbey Road",
    "artistName": "The Beatles",
    "releaseYear": 1969,
    "artworkUrl100": "https://example.com/image.jpg"
  }
]
```

**DTO модель** → `AlbumDTO` (с `Codable`):
- `id: String`
- `collectionName: String` → Domain модель `Album.title`
- `artistName: String`
- `releaseYear: Int` (хранится напрямую)
- `artworkUrl100: String?` (для будущего UI)

**Domain модель** → `Album` (Entity):
- `id: String`
- `title: String`
- `artistName: String`
- `releaseYear: Int`
- `artworkUrl: String?`

**CellViewModel** → `AlbumCellViewModel` (готовая модель для View слоя):
- `id: String`
- `title: String`
- `artistName: String`
- `releaseYear: Int`
- `artworkUrl: String?`

**Сценарии:**
1. Открылся экран → `didLoad()` → `fetchAlbums()` async → `loading` → `content([AlbumCellViewModel])`
2. Успешная загрузка → состояние `content` с маппированными моделями
3. Пустой результат → состояние `empty`
4. Ошибка сети → **fallback на локальный JSON** из `albums.json` (D3: локальный fallback для отладки)
5. Нажал Retry → `didTapRetry()` → повторная загрузка с отменой предыдущего Task (D2: cancellation)

**Обработка ошибок:**
- `NetworkError.invalidURL` → "Неверный URL"
- `NetworkError.badServerResponse(statusCode)` → "Ошибка сервера: статус XXX"
- `NetworkError.decodingError(message)` → "Ошибка парсинга данных: ..."
- `NetworkError.timeout` → "Превышено время ожидания"
- `NetworkError.networkError(message)` → "Ошибка сети: ..."

**Архитектурные компоненты:**
- `NetworkClient` (протокол) + `URLSessionNetworkClient` (реализация) — вынесены в отдельный модуль `Network/`
- `CatalogRepository` реализует `CatalogRepositoryProtocol`, делает сетевой запрос через `NetworkClient`
- `CatalogService` (реализует `CatalogServiceProtocol`) — делегирует в репозиторий
- `CatalogViewModel` получает зависимость через протокол и управляет состоянием
- UI слой (`CatalogViewController` заглушка) не содержит бизнес-логики

Сценарии:
1. Открылся экран → `didLoad` → `fetchAlbums` → `loading` → `content`
2. Ввёл поисковый запрос → `didSearch(query:)` → `search` → `content`
3. Ошибка загрузки → `error` → нажал Retry → `didTapRetry` → повторная загрузка
4. Нажал на альбом → `didSelectAlbum(id:)` → переход в TrackDetail


### Дополнительные возможности (Допы)

**D1: Нормальная модель ошибок** ✓
- Собственный enum `NetworkError` с типами: `invalidURL`, `badServerResponse`, `decodingError`, `networkError`, `timeout`, `unknown`
- Каждая ошибка имеет `errorDescription` для локализации
- В ViewModel ошибки маппятся в текст состояния

**D2: Отмена запроса (cancellation)** ✓
- При повторном вызове `didLoad()` или `didLoadMore()` предыдущий Task отменяется через `loadingTask?.cancel()`
- Предотвращает race condition и лишние обновления UI

**D3: Локальный fallback** ✓
- При недоступности сети используется локальный файл `albums.json`
- Флаг `useLocalFallback = true` управляет поведением
- Позволяет тестировать без интернета

**D4: Пагинация** ✓
- Контракт: `fetchAlbums(page: Int, pageSize: Int)` в Repository/Service/ViewModel
- `CatalogRepository` кэширует все альбомы в памяти и возвращает срезы по страницам
- `CatalogViewModel.didLoadMore()` загружает следующую страницу, добавляя новые альбомы к существующим
- Стандартный размер страницы: 10 альбомов

**D5: Кэширование** ✓
- Generic `CacheManager<Key, Value>` с TTL (по умолчанию 5 минут = 300 сек)
- Сохраняет полный список альбомов в памяти с временем истечения
- `CatalogViewModel.clearCache()` очищает кэш и перезагружает данные
- Методы: `set()`, `get()`, `clear()`, `clearExpired()`
- При повторной загрузке в течение TTL возвращается кэшированное значение


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

После успешной авторизации открывается экран каталога (`CatalogViewController`) со списком альбомов:

- Отображается приветствие с именем пользователя из сессии.
- Подпись: «Каталог альбомов (в разработке)».

При неверных данных — под кнопкой появляется красный текст ошибки «Неверный email или пароль».

---

- **Сделан доп**
ошибки под полями в реальном времени (email-формат, длина пароля)


## Скриншоты

![Экран авторизации](https://github.com/antoha124/Alfa-music/blob/lab-3/Alfa-music/Photo/main.png?raw=true)
![Ошибка валидации](https://github.com/antoha124/Alfa-music/blob/lab-3/Alfa-music/Photo/valid.png?raw=true)
![Экран каталога](https://github.com/antoha124/Alfa-music/blob/lab-3/Alfa-music/Photo/user.png?raw=true)
![Экран каталога](https://github.com/antoha124/Alfa-music/blob/lab-3/Alfa-music/Photo/guest.png?raw=true)
