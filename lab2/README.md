# Лабораторна робота 2. Створення складних SQL запитів

## Загальна інформація

**Здобувач освіти:** Нестерук Павло Романович
**Група:** ІПЗ-31
**Обраний рівень складності:** 3

## Виконання завдань

### Рівень 1

#### 1. З'єднання таблиць

**Завдання 1.1:** INNER JOIN - список товарів з категоріями та постачальниками

```sql
-- список товарів з назвами категорій та постачальників

select 
    p.product_name, 
    c.category_name, 
    s.company_name, 
    p.unit_price
from 
    products p
inner join 
    categories c on p.category_id = c.category_id
inner join 
    suppliers s on p.supplier_id = s.supplier_id
order by 
    c.category_name, 
    p.product_name

```

**Результат виконання:**
```
| product_name                           | category_name             | company_name                  | unit_price |
| -------------------------------------- | ------------------------- | ----------------------------- | ---------- |
| Бездротова клавіатура Logitech MX Keys | Аксесуари та комплектуючі | ТОВ "Львівські комп'ютери"    | 3999.00    |
| Зарядний кабель USB-C 2м               | Аксесуари та комплектуючі | ПП "Прикарпатські технології" | 699.00     |
| Навушники Apple AirPods Pro 2          | Аксесуари та комплектуючі | ПП "Комп'ютерні технології"   | 8999.00    |
| Nintendo Switch OLED 64GB              | Ігрові консолі та ігри    | ТОВ "Електроніка Плюс"        | 12999.00   |
| PlayStation 5 825GB                    | Ігрові консолі та ігри    | ТОВ "Мобільний світ"          | 17999.00   |
| Xbox Series X 1TB                      | Ігрові консолі та ігри    | ПАТ "Дніпро Електронікс"      | 16999.00   |
| ASUS ROG Strix G15 RTX 4060 1TB        | Ноутбуки та комп'ютери    | ТОВ "Мобільний світ"          | 42999.00   |
| Dell XPS 13 Plus Intel i7 512GB        | Ноутбуки та комп'ютери    | ПАТ "Дніпро Електронікс"      | 52999.00   |
| HP Pavilion 15 AMD Ryzen 7 512GB       | Ноутбуки та комп'ютери    | ТОВ "Запорізька електроніка"  | 28999.00   |
| Lenovo ThinkPad X1 Carbon Gen 11       | Ноутбуки та комп'ютери    | ТОВ "Львівські комп'ютери"    | 48999.00   |

```

**Пояснення:** Запит виводить список товарів з назвами категорій, постачальниками та ціною за шт. До основної таблиці товарів "products" доєднуються категорії "categories" та постачальники "suppliers". З'єднання відбувається через inner join. Сортуємо за іменами категорій та товарів.



**Завдання 1.2:** LEFT JOIN - клієнти з кількістю замовлень

```sql
-- отримати всіх клієнтів, включаючи тих, хто не має замовлень

select 
    c.contact_name, 
    c.customer_type, 
    r.region_name, 
    count(o.order_id) as order_count
from 
    customers c
left join 
    orders o on c.customer_id = o.customer_id
inner join 
    regions r on c.region_id = r.region_id
group by 
    c.customer_id, 
    c.contact_name, 
    c.customer_type, 
    r.region_name
order by 
    order_count desc;

```

**Результат виконання:**
```
| contact_name                   | customer_type | region_name              | order_count |
| ------------------------------ | ------------- | ------------------------ | ----------- |
| Петров Іван Миколайович        | individual    | м. Київ                  | 3           |
| Іванова Марія Сергіївна        | individual    | Харківська область       | 2           |
| Гриценко Наталія Володимирівна | individual    | Одеська область          | 2           |
| Кравченко Максим Олександрович | individual    | Львівська область        | 2           |
| Шевченко Віктор Олександрович  | company       | Харківська область       | 2           |
| Сидоренко Тетяна Миколаївна    | individual    | Львівська область        | 2           |
| Коваленко Андрій Петрович      | company       | м. Київ                  | 2           |
| Морозенко Сергій Миколайович   | company       | Дніпропетровська область | 2           |
| Мельник Ольга Іванівна         | individual    | Львівська область        | 2           |
| Федоренко Ірина Петрівна       | company       | м. Київ                  | 2           |

```

**Пояснення:** Включаємо у результат користувачів, без замовлень, за допомогою Left join. За допомогою inner join виключаємо тих користувачів, яким не приділений регіон



**Завдання 1.3:** Множинне з'єднання - детальна інформація про замовлення

```sql
-- детальна інформація про замовлення (замовник; замовлені товари; обслуговуюючий працівник; дата замовлення)

select 
    c.contact_name as customer,
    -- відображає замовлені продукти та їх кількість; використовується конкатенація - з'єднання рядків
    string_agg((ord_it.quantity || 'x ' || p.product_name), ' | ') as ordered_products, 
    -- відображає повне ім'я (ім'я + прізвище) працівника, що обслуговує замовлення
    emp.first_name || ' ' || emp.last_name as served_by as served_by,
    -- рахує суму замовлення разом із знижкою
    sum(ord_it.unit_price * (1 - ord_it.discount) * ord_it.quantity) as order_sum,
    ord.order_date
from 
    orders ord
inner join 
    customers c on ord.customer_id = c.customer_id
inner join 
    employees emp on ord.employee_id = emp.employee_id
inner join 
    order_items ord_it on ord.order_id = ord_it.order_id
inner join 
    products p on ord_it.product_id = p.product_id
group by 
    ord.order_id, 
    c.contact_name, 
    served_by
order by 
    ord.order_id

```

**Результат виконання:**
```
| customer                       | ordered_products                                                                   | served_by        | order_sum   | order_date |
| ------------------------------ | ---------------------------------------------------------------------------------- | ---------------- | ----------- | ---------- |
| Петров Іван Миколайович        | 1x Xiaomi Redmi Note 13 Pro 128GB Синій | 2x Мікрохвильова піч Panasonic NN-ST45KW | Марія Коваленко  | 13747.0500  | 2024-01-15 |
| Коваленко Андрій Петрович      | 2x MacBook Air M2 13" 256GB Сріблястий | 2x iPad Air M2 11" 128GB Синій            | Марія Коваленко  | 90396.3000  | 2024-01-20 |
| Іванова Марія Сергіївна        | 1x iPhone 15 128GB Чорний | 1x Пральна машина LG F4V5VS6W 9кг                      | Наталія Гриценко | 38998.0000  | 2024-01-22 |
| Мельник Ольга Іванівна         | 1x Пральна машина LG F4V5VS6W 9кг | 1x Мікрохвильова піч Panasonic NN-ST45KW       | Андрій Мельник   | 9698.0000   | 2024-02-01 |
| Шевченко Віктор Олександрович  | 1x Dell XPS 13 Plus Intel i7 512GB | 1x ASUS ROG Strix G15 RTX 4060 1TB            | Наталія Гриценко | 88318.1600  | 2024-02-10 |
| Гриценко Наталія Володимирівна | 1x Samsung Galaxy Tab S9+ 256GB                                                    | Тетяна Сидоренко | 17999.0000  | 2024-02-18 |
| Білоус Дмитро Сергійович       | 3x Lenovo ThinkPad X1 Carbon Gen 11 | 3x iPad Air M2 11" 128GB Синій               | Марія Коваленко  | 140154.6600 | 2024-02-25 |
| Сидоренко Тетяна Миколаївна    | 1x TCL C845 Mini LED 65" 4K | 2x Мікрохвильова піч Panasonic NN-ST45KW             | Андрій Мельник   | 25397.0000  | 2024-03-05 |
| Павленко Олексій Іванович      | 1x Samsung Galaxy S24 256GB Фіолетовий                                             | Наталія Гриценко | 27159.0300  | 2024-03-12 |
| Федоренко Ірина Петрівна       | 1x OnePlus 12 256GB Зелений | 2x Samsung QLED QE55Q80C 55" 4K                      | Марія Коваленко  | 80197.4000  | 2024-03-18 |

```

**Аналіз складності:** Даний запит є відносно складним: по-більшості через багатотабличне з'єднання та агрегацію. Основна таблиця - замовлення. До неї доєднуємо таблицю клієнтів -> працівники -> замовлені товари -> товари. 



#### 2. Агрегатні функції

**Завдання 2.1:** Статистика товарів за категоріями

```sql
--підрахувати кількість товарів у кожній категорії та середню ціну
select c.category_name,
        count(p.product_id) as product_count,
    avg(p.unit_price) as avg_price,
    min(p.unit_price) as min_price,
    max(p.unit_price) as max_price
from 
    categories c
left join 
    products p on c.category_id = p.category_id
group by 
    c.category_id, 
    c.category_name
order by 
    product_count desc;

```

**Результат виконання:**
```
| category_name                | product_count | avg_price             | min_price | max_price |
| ---------------------------- | ------------- | --------------------- | --------- | --------- |
| Смартфони та телефони        | 5             | 23799.000000000000    | 12999.00  | 29999.00  |
| Ноутбуки та комп'ютери       | 5             | 43999.000000000000    | 28999.00  | 52999.00  |
| Телевізори та аудіо          | 4             | 46749.000000000000    | 29999.00  | 62999.00  |
| Аксесуари та комплектуючі    | 3             | 4565.6666666666666667 | 699.00    | 8999.00   |
| Побутова техніка             | 3             | 17665.666666666667    | 4999.00   | 28999.00  |
| Ігрові консолі та ігри       | 3             | 15999.000000000000    | 12999.00  | 17999.00  |
| Планшети та електронні книги | 2             | 28499.000000000000    | 23999.00  | 32999.00  |
| Розумний дім                 | 0             | null                  | null      | null      |
| Спортивні технології         | 0             | null                  | null      | null      |
| Фото та відео                | 0             | null                  | null      | null      |    

```

**Завдання 2.2:** Продажі за регіонами з використанням HAVING

```sql
-- визначити загальні продажі за регіонами
select 
  r.region_name,
  -- рахуємо суму всіх замовлень по регіону, разом зі знижками
  sum(ord_it.unit_price * (1 - ord_it.discount) * ord_it.quantity) as sell_sum_overall
from 
    regions r
/*використовуємо left join для відображення всіх регіонів, 
не зважаючи, чи були зроблені туди замовлення*/
left join 
    orders ord on r.region_id = ord.ship_region_id
left join 
    order_items ord_it on ord.order_id = ord_it.order_id
group by 
    r.region_id, 
    r.region_name
having 
    sum(ord_it.unit_price * (1 - ord_it.discount) * ord_it.quantity) > 0
-- сортуємо по ціні descending
order by 
    sell_sum_overall desc;

```

**Результат виконання:**
```
| region_name              | sell_sum_overall |
| ------------------------ | ---------------- |
| Дніпропетровська область | 894191.6400      |
| м. Київ                  | 889560.6600      |
| Харківська область       | 333315.0000      |
| Одеська область          | 90796.0500       |
| Львівська область        | 64062.7500       |

```

**Завдання 2.3:** Постачальники з кількістю товарів більше 2

```sql
-- знайти постачальників з кількістю товарів більше 2

select 
  s.company_name,
  -- обчислюємо кількість продуктів на одного постачальника
  count(p.product_id) as supplied_products
from 
    suppliers s 
left join 
    products p on s.supplier_id = p.supplier_id
group by 
    s.supplier_id, s.company_name
-- не можемо використовувати aliases в having
having 
    count(p.product_id) > 2
-- сортуємо по спаданню за кількістю товарів
order by 
    supplied_products desc;

```

**Результат виконання:**
```
| company_name                | supplied_products |
| --------------------------- | ----------------- |
| ТОВ "Електроніка Плюс"      | 6                 |
| ПП "Комп'ютерні технології" | 5                 |
| ТОВ "Мобільний світ"        | 4                 |
| ТОВ "Техно Імпорт"          | 3                 |

```



#### 3. Базові підзапити

**Завдання 3.1:** Товари з ціною вище середньої по категорії

```sql
-- знайти товари з ціною вищою за середню ціну товарів у своїй категорії

select 
  p.product_name, 
  p.unit_price, 
  c.category_name
from 
    products p
inner join 
    categories c on p.category_id = c.category_id
where 
    p.unit_price > (
    select 
        avg(p2.unit_price)
    from 
        products p2
    where 
        p2.category_id = p.category_id
)
order by 
    c.category_name, 
    p.unit_price desc;


```

**Результат виконання:**
```
| product_name                        | unit_price | category_name                |
| ----------------------------------- | ---------- | ---------------------------- |
| Навушники Apple AirPods Pro 2       | 8999.00    | Аксесуари та комплектуючі    |
| PlayStation 5 825GB                 | 17999.00   | Ігрові консолі та ігри       |
| Xbox Series X 1TB                   | 16999.00   | Ігрові консолі та ігри       |
| Dell XPS 13 Plus Intel i7 512GB     | 52999.00   | Ноутбуки та комп'ютери       |
| Lenovo ThinkPad X1 Carbon Gen 11    | 48999.00   | Ноутбуки та комп'ютери       |
| MacBook Air M2 13" 256GB Сріблястий | 45999.00   | Ноутбуки та комп'ютери       |
| Samsung Galaxy Tab S9+ 256GB        | 32999.00   | Планшети та електронні книги |
| Холодильник Samsung RB38T7762SA/UA  | 28999.00   | Побутова техніка             |
| Пральна машина LG F4V5VS6W 9кг      | 18999.00   | Побутова техніка             |
| iPhone 15 128GB Чорний              | 29999.00   | Смартфони та телефони        |

```

**Завдання 3.2:** Клієнти з замовленнями у 2024 році

```sql
-- Отримати клієнтів, які мали замовлення у 2024 році

select
  c.customer_id,
  c.contact_name
from 
    customers c
where 
    customer_id in (
    select 
        distinct ord.customer_id
    from 
        orders ord
    where 
        extract(year from ord.order_date) = 2024
);

```

**Результат виконання:**
```
| customer_id | contact_name                   |
| ----------- | ------------------------------ |
| 1           | Петров Іван Миколайович        |
| 2           | Іванова Марія Сергіївна        |
| 3           | Коваленко Андрій Петрович      |
| 4           | Мельник Ольга Іванівна         |
| 5           | Шевченко Віктор Олександрович  |
| 6           | Гриценко Наталія Володимирівна |
| 7           | Білоус Дмитро Сергійович       |
| 8           | Сидоренко Тетяна Миколаївна    |
| 9           | Павленко Олексій Іванович      |
| 10          | Федоренко Ірина Петрівна       |

```

**Завдання 3.3:** Товари з загальною кількістю продажів

```sql
-- Додати до списку товарів інформацію про загальну кількість продажів

select 
  p.product_name,
  coalesce(
    (
        select 
            sum(ord_it.quantity) 
        from 
            order_items ord_it 
        where 
            p.product_id=ord_it.product_id
    ), 0) as total_sold
from 
    products p
order by 
    total_sold desc;
```

**Результат виконання:**
```
| product_name                          | total_sold |
| ------------------------------------- | ---------- |
| iPad Air M2 11" 128GB Синій           | 19         |
| MacBook Air M2 13" 256GB Сріблястий   | 15         |
| Мікрохвильова піч Panasonic NN-ST45KW | 13         |
| Lenovo ThinkPad X1 Carbon Gen 11      | 7          |
| Dell XPS 13 Plus Intel i7 512GB       | 6          |
| Пральна машина LG F4V5VS6W 9кг        | 6          |
| Samsung QLED QE55Q80C 55" 4K          | 5          |
| ASUS ROG Strix G15 RTX 4060 1TB       | 4          |
| iPhone 15 128GB Чорний                | 4          |
| Xiaomi Redmi Note 13 Pro 128GB Синій  | 3          |
```



### Рівень 2

#### 4. Складні з'єднання

**Завдання 4.1:** RIGHT JOIN - аналіз категорій та товарів

```sql
-- RIGHT JOIN для аналізу категорій товарів та їх наявності

select 
  c.category_name,
  count(p.product_id) as products_count,
  coalesce(avg(p.unit_price), 0) as avg_price
from 
  products p
right join
  categories c on p.category_id = c.category_id
group by
  c.category_id,
  c.category_name
order by
  products_count desc;
```

**Результат виконання:**
```
| category_name                | products_count | avg_price             |
| ---------------------------- | -------------- | --------------------- |
| Смартфони та телефони        | 5              | 23799.000000000000    |
| Ноутбуки та комп'ютери       | 5              | 43999.000000000000    |
| Телевізори та аудіо          | 4              | 46749.000000000000    |
| Аксесуари та комплектуючі    | 3              | 4565.6666666666666667 |
| Побутова техніка             | 3              | 17665.666666666667    |
| Ігрові консолі та ігри       | 3              | 15999.000000000000    |
| Планшети та електронні книги | 2              | 28499.000000000000    |
| Розумний дім                 | 0              | 0                     |
| Спортивні технології         | 0              | 0                     |
| Фото та відео                | 0              | 0                     |

```

**Завдання 4.2:** Self-join - співробітники та керівники

```sql
-- Self-join для знаходження співробітників та їх керівників

select 
  e1.first_name || ' ' || e1.last_name as employee,
  e1.title as employee_title,
  e2.first_name || ' ' || e2.last_name as manager,
  e2.title as manager_title
from
  employees e1
left join
  employees e2 on e1.reports_to = e2.employee_id
order by 
  e2.last_name,
  e1.last_name;

```

**Результат виконання:**
```
| employee           | employee_title         | manager            | manager_title         |
| ------------------ | ---------------------- | ------------------ | --------------------- |
| Дмитро Білоус      | Менеджер зі складу     | Сергій Іваненко    | Менеджер з закупівель |
| Тетяна Сидоренко   | Спеціаліст з логістики | Сергій Іваненко    | Менеджер з закупівель |
| Наталія Гриценко   | Менеджер з продажу     | Марія Коваленко    | Менеджер з продажу    |
| Андрій Мельник     | Менеджер з продажу     | Марія Коваленко    | Менеджер з продажу    |
| Сергій Іваненко    | Менеджер з закупівель  | Олександр Петренко | Генеральний директор  |
| Марія Коваленко    | Менеджер з продажу     | Олександр Петренко | Генеральний директор  |
| Ольга Шевченко     | Головний бухгалтер     | Олександр Петренко | Генеральний директор  |
| Олександр Петренко | Генеральний директор   | null               | null                  |
```



#### 5. Віконні функції

**Завдання 5.1:** Ранжування товарів за ціною в категоріях

```sql
-- Ранжувати товари за ціною в межах категорії
select
    p.product_name,
    c.category_name,
    rank() over (partition by c.category_name order by p.unit_price desc) as price_rank,
    dense_rank() over (partition by c.category_name order by p.unit_price desc) as price_dense_rank,
    row_number() over (partition by c.category_name order by p.unit_price desc) as row_num
from
    products p
join
    categories c on p.category_id = c.category_id
order by
    c.category_name, p.unit_price desc

```

**Результат виконання:**
```
| product_name                           | category_name             | price_rank | price_dense_rank | row_num |
| -------------------------------------- | ------------------------- | ---------- | ---------------- | ------- |
| Навушники Apple AirPods Pro 2          | Аксесуари та комплектуючі | 1          | 1                | 1       |
| Бездротова клавіатура Logitech MX Keys | Аксесуари та комплектуючі | 2          | 2                | 2       |
| Зарядний кабель USB-C 2м               | Аксесуари та комплектуючі | 3          | 3                | 3       |
| PlayStation 5 825GB                    | Ігрові консолі та ігри    | 1          | 1                | 1       |
| Xbox Series X 1TB                      | Ігрові консолі та ігри    | 2          | 2                | 2       |
| Nintendo Switch OLED 64GB              | Ігрові консолі та ігри    | 3          | 3                | 3       |
| Dell XPS 13 Plus Intel i7 512GB        | Ноутбуки та комп'ютери    | 1          | 1                | 1       |
| Lenovo ThinkPad X1 Carbon Gen 11       | Ноутбуки та комп'ютери    | 2          | 2                | 2       |
| MacBook Air M2 13" 256GB Сріблястий    | Ноутбуки та комп'ютери    | 3          | 3                | 3       |
| ASUS ROG Strix G15 RTX 4060 1TB        | Ноутбуки та комп'ютери    | 4          | 4                | 4       |

```

**Завдання 5.2:** Порівняння замовлень з попередніми датами

```sql
-- Порівняти замовлення кожного клієнта з попереднім за датою

-- CTE, що обчислює загальну суму кожного замовлення, включно із знижкою
with orders_totals as (select 
    o.customer_id,
    o.order_id,
    o.order_date,
    round(sum(oi.quantity * oi.unit_price * (1 - oi.discount)), 2) as order_price
from
    orders o
inner join 
    order_items oi on o.order_id = oi.order_id
group by
    o.order_id,
    o.customer_id
)

select
    c.contact_name,
    ot.order_id,
    -- обчислює попередню дату замовлення
    lag(ot.order_date, 1) over (partition by ot.customer_id order by ot.order_date) as prev_order_date,
    ot.order_date,
    -- обчислює скільки пройшло часу між останнім замовленням і наступним (0, якщо наступного немає)
    coalesce(
        lead(ot.order_date, 1) over (partition by ot.customer_id order by ot.order_date) - ot.order_date, 0
    ) || ' days' as days_between_orders,
    ot.order_price,
    -- обчислює різницю суми теперішнього замовлення із попереднім (сума теперішнього віднімається від попереднього)
    '$' || coalesce(
        ot.order_price - lag(ot.order_price, 1) over (partition by ot.customer_id order by ot.order_date), 0
    ) as prev_order_price_diff
from
    orders_totals ot
inner join
    customers c on ot.customer_id = c.customer_id
order by
    ot.customer_id,
    ot.order_date
```

**Результат виконання:**
```
| contact_name                  | order_id | prev_order_date | order_date | days_between_orders | order_price | prev_order_price_diff |
| ----------------------------- | -------- | --------------- | ---------- | ------------------- | ----------- | --------------------- |
| Петров Іван Миколайович       | 1        | null            | 2024-01-15 | 107 days            | 13747.05    | $0                    |
| Петров Іван Миколайович       | 16       | 2024-01-15      | 2024-05-01 | 101 days            | 57959.08    | $44212.03             |
| Петров Іван Миколайович       | 28       | 2024-05-01      | 2024-08-10 | 0 days              | 17098.10    | $-40860.98            |
| Іванова Марія Сергіївна       | 3        | null            | 2024-01-22 | 109 days            | 38998.00    | $0                    |
| Іванова Марія Сергіївна       | 17       | 2024-01-22      | 2024-05-10 | 0 days              | 25846.05    | $-13151.95            |
| Коваленко Андрій Петрович     | 2        | null            | 2024-01-20 | 152 days            | 90396.30    | $0                    |
| Коваленко Андрій Петрович     | 22       | 2024-01-20      | 2024-06-20 | 0 days              | 166596.60   | $76200.30             |
| Мельник Ольга Іванівна        | 4        | null            | 2024-02-01 | 107 days            | 9698.00     | $0                    |
| Мельник Ольга Іванівна        | 18       | 2024-02-01      | 2024-05-18 | 0 days              | 3999.00     | $-5699.00             |
| Шевченко Віктор Олександрович | 5        | null            | 2024-02-10 | 142 days            | 88318.16    | $0                    |
```



### Рівень 3

#### 6. Матеріалізовані представлення та рекурсивні запити

**Завдання 6.1:** Матеріалізоване представлення для аналізу продажів

```sql
-- Створити матеріалізоване представлення для аналізу продажів
create materialized view mv_monthly_sales as
    select
        extract(year from o.order_date) as year,
        extract(month from o.order_date) as month,
        c.category_name,
        r.region_name,
        sum(oi.quantity * oi.unit_price * (1 - oi.discount)) as total_revenue,
        count(distinct o.order_id) as orders_count,
        avg(oi.quantity * oi.unit_price * (1 - oi.discount)) as avg_order_value
    from
        orders o 
    join 
        order_items oi on o.order_id = oi.order_id
    join 
        products p on oi.product_id = p.product_id
    join 
        categories c on p.category_id = c.category_id
    join 
        customers cu on o.customer_id = cu.customer_id
    left join 
        regions r on cu.region_id = r.region_id
    where
        o.order_status = 'delivered'
    group by
        year,
        month,
        c.category_name,
        r.region_name;

create index idx_mv_monthly_sales_date on mv_monthly_sales(year, month);
```

**Пояснення:** Матеріалізовані представлення добре підходять для складних та комплексних засобів, що не потребують постійного оновлення. Тобто, створити таблицю з найбільш запитуваними даними, що не оновлюються часто. Це дозволяє оптимізувати роботу.

**Завдання 6.2:** Рекурсивний запит для ієрархії співробітників

```sql
-- Реалізувати рекурсивний запит для ієрархії керівників
with recursive employee_hierarchy as (
    select
        employee_id,
        first_name,
        last_name,
        title,
        reports_to,
        0 as level,
    cast(
        last_name || ' ' || first_name as varchar(1000)
    ) as hierarchy_path
    from
        employees
    where
        reports_to is null

    union all

    select 
        e.employee_id,
        e.first_name,
        e.last_name,
        e.title,
        e.reports_to,
        eh.level + 1,
        cast(
            eh.hierarchy_path || ' -> ' || e.last_name || ' ' || e.first_name as varchar(1000)
        )
        from
        employees e
        join
        employee_hierarchy eh on e.reports_to = eh.employee_id
)

select
    *
from
    employee_hierarchy
order by
    hierarchy_path
```

**Результат виконання:**
```
| employee_id | first_name | last_name | title                  | reports_to | level | hierarchy_path                                            |
| ----------- | ---------- | --------- | ---------------------- | ---------- | ----- | --------------------------------------------------------- |
| 1           | Олександр  | Петренко  | Генеральний директор   | null       | 0     | Петренко Олександр                                        |
| 3           | Сергій     | Іваненко  | Менеджер з закупівель  | 1          | 1     | Петренко Олександр -> Іваненко Сергій                     |
| 7           | Дмитро     | Білоус    | Менеджер зі складу     | 3          | 2     | Петренко Олександр -> Іваненко Сергій -> Білоус Дмитро    |
| 8           | Тетяна     | Сидоренко | Спеціаліст з логістики | 3          | 2     | Петренко Олександр -> Іваненко Сергій -> Сидоренко Тетяна |
| 2           | Марія      | Коваленко | Менеджер з продажу     | 1          | 1     | Петренко Олександр -> Коваленко Марія                     |
| 6           | Наталія    | Гриценко  | Менеджер з продажу     | 2          | 2     | Петренко Олександр -> Коваленко Марія -> Гриценко Наталія |
| 5           | Андрій     | Мельник   | Менеджер з продажу     | 2          | 2     | Петренко Олександр -> Коваленко Марія -> Мельник Андрій   |
| 4           | Ольга      | Шевченко  | Головний бухгалтер     | 1          | 1     | Петренко Олександр -> Шевченко Ольга                      |
```



## Аналіз продуктивності

### Дослідження планів виконання

**Найповільніший запит:**
```sql
explain(analyse, buffers)
with recursive employee_hierarchy as (
    select
        employee_id,
        first_name,
        last_name,
        title,
        reports_to,
        0 as level,
    cast(
        last_name || ' ' || first_name as varchar(1000)
    ) as hierarchy_path
    from
        employees
    where
        reports_to is null

    union all

    select 
        e.employee_id,
        e.first_name,
        e.last_name,
        e.title,
        e.reports_to,
        eh.level + 1,
        cast(
        eh.hierarchy_path || ' -> ' || e.last_name || ' ' || e.first_name as varchar(1000)
        )
        from
        employees e
        join
        employee_hierarchy eh on e.reports_to = eh.employee_id
)

select
    *
from
    employee_hierarchy
order by
    hierarchy_path
```

**План виконання (EXPLAIN ANALYZE):**
```
| QUERY PLAN                                                                                                                                 |
| ------------------------------------------------------------------------------------------------------------------------------------------ |
| Sort  (cost=22.26..22.46 rows=81 width=882) (actual time=0.140..0.142 rows=8 loops=1)                                                      |
|   Sort Key: employee_hierarchy.hierarchy_path                                                                                              |
|   Sort Method: quicksort  Memory: 26kB                                                                                                     |
|   Buffers: shared hit=5                                                                                                                    |
|   CTE employee_hierarchy                                                                                                                   |
|     ->  Recursive Union  (cost=0.00..18.07 rows=81 width=882) (actual time=0.021..0.068 rows=8 loops=1)                                    |
|           Buffers: shared hit=2                                                                                                            |
|           ->  Seq Scan on employees  (cost=0.00..1.09 rows=1 width=882) (actual time=0.019..0.023 rows=1 loops=1)                          |
|                 Filter: (reports_to IS NULL)                                                                                               |
|                 Rows Removed by Filter: 7                                                                                                  |
|                 Buffers: shared hit=1                                                                                                      |
|           ->  Hash Join  (cost=1.18..1.62 rows=8 width=882) (actual time=0.012..0.013 rows=2 loops=3)                                      |
|                 Hash Cond: (eh.employee_id = e.reports_to)                                                                                 |
|                 Buffers: shared hit=1                                                                                                      |
|                 ->  WorkTable Scan on employee_hierarchy eh  (cost=0.00..0.20 rows=10 width=524) (actual time=0.000..0.000 rows=3 loops=3) |
|                 ->  Hash  (cost=1.08..1.08 rows=8 width=362) (actual time=0.015..0.015 rows=7 loops=1)                                     |
|                       Buckets: 1024  Batches: 1  Memory Usage: 9kB                                                                         |
|                       Buffers: shared hit=1                                                                                                |
|                       ->  Seq Scan on employees e  (cost=0.00..1.08 rows=8 width=362) (actual time=0.008..0.010 rows=8 loops=1)            |
|                             Buffers: shared hit=1                                                                                          |
|   ->  CTE Scan on employee_hierarchy  (cost=0.00..1.62 rows=81 width=882) (actual time=0.024..0.074 rows=8 loops=1)                        |
|         Buffers: shared hit=2                                                                                                              |
| Planning:                                                                                                                                  |
|   Buffers: shared hit=178                                                                                                                  |
| Planning Time: 0.647 ms                                                                                                                    |
| Execution Time: 0.267 ms                                                                                                                   |
```

**Запропоновані оптимізації:**
1. Створити матеріалізаване представлення якщо дані не будуть змінюватися часто.
2. Проіндексувати поле report_to в таблиці employees, якщо запит буде виконуватися часто. 
3. Можна обмежити глибину рекурсії, якщо не потрібний повний список.

### Створені індекси

**Індекс 1:**
```sql
create index idx_products_category_price on products(category_id, unit_price);

```
**Обґрунтування:** Можуть часто використовувати пошук товарів за категорією та ціною (всі товари в категорії "n", найнижча/найвища/середня ціна в категорії тощо)

**Індекс 2:**
```sql
create index idx_employee_name on employees(last_name, first_name)

```
**Обґрунтування:** Часто виникає потреба у пошуку працівника за його ім'ям та прізвищем



## Порівняльний аналіз

### Ефективність різних підходів

**Завдання:** Знайти топ-5 найдорожчих товарів у кожній категорії

**Підхід 1: Віконні функції**
```sql
with product_price_ranking as (select
    c.category_name,
    p.product_name,
    p.unit_price,
    dense_rank() over (partition by c.category_id order by p.unit_price desc) as price_rank
from
    categories c
left join
    products p on c.category_id = p.category_id
)

select
  *
from
  product_price_ranking
where
  price_rank <= 5

```

**Підхід 2: Корельований підзапит**
```sql
select 
    c.category_name,
    p1.product_name,
    p1.unit_price,
    (
        select
        count(*)
        from
        products p2
        where
        p1.category_id = p2.category_id and p2.unit_price > p1.unit_price
    ) + 1 as price_rank
from
    categories c
left join
    products p1 on c.category_id = p1.category_id
where (
    select
        count(*)
    from
        products p2
    where
        p1.category_id = p2.category_id and p2.unit_price > p1.unit_price
) < 5
order by
    c.category_id,
    c.category_name,
    price_rank
```

**Час виконання:**
- Віконні функції: 0.281/0.278/0.286/0.308 ms
- Корельований підзапит: 2.045/0.625/0.632/0.629 ms

**Висновок:** Корельований запит не найкращий вибір для обчислення топ-5 найдорожчих товарів у кожній категорії. Він працює набагато повільніше, ніж аналогічний, що виконується із віконною функцією. Також, варто зазначити, що читабельність корельованого запиту теж значно нижча. 



## Висновки

**Самооцінка**: 5

**Обгрунтування**: Лабораторна робота була зроблена повністю, на найвищому рівні складності та згідно всіх вимого