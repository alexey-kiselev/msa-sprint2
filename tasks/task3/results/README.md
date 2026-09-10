# Задание 3. Личный кабинет - изменения

GraphQL Federation из трёх частей.

- **booking-subgraph (:4001):**
  - Запрос `bookingsByUser(userId)`
  - gRPC в `booking-service`, ACL - только если запрашиваемый `userid` совпадает с заголовком, иначе пусто

- **hotel-subgraph (:4002):**
  - Тип `Hotel`, REST из монолита

- **apollo-gateway (:4000):**
  - Объединяет booking и hotel, передаёт HTTP-заголовки (`userid`) в подграфы
