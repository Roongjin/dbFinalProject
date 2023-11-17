--------- 1 ---------------------
---- query data of timeslots of 'Pet sitting', 'Dog walking', or 'Grooming' from service provider who have more than 4.5 average rating of EVERY services they have.
---- the start time of that timeslot also have to be after '2023-11-17 15:00:00+00'
SELECT
    S.average_rating,
    T.starttime,
    T.endtime,
    T.service_type,
    T.price,
    T.capacity,
    S.service_img
FROM
    timeslot T,
    service S
WHERE
    T.service_type = S.service_type
    AND S.service_type IN ('Grooming', 'Dog walking', 'Pet sitting')
    AND T.individual_id = S.individual_id
    AND S.individual_id IN (
        SELECT
            individual_id
        FROM
            service
        GROUP BY
            individual_id
        HAVING
            avg(average_rating) > 4.5)
    AND T.starttime >= '2023-11-17 15:00:00+00';

--------- 2 ---------------------
---- find the user who may be a scam such that they have made more than 2 bookings and they always got total refund on their booking
---- or they repeatedly(more than 2 times) rate one service with lower than 1.5 rating.
SELECT DISTINCT
    B.individual_id
FROM
    booking B
WHERE
    B.individual_id IN ((
        SELECT
            individual_id
        FROM booking
        WHERE
            refund_value = total_booking_value
            AND refund_status NOT IN ('NoRefund')
    GROUP BY individual_id, payout_payment_id
    HAVING
        count(*) >= 3)
UNION (
    SELECT
        individual_id
    FROM booking GROUP BY individual_id, payout_payment_id
HAVING
    count(*) >= 3
AND avg(rating) < 1.5));

--------- 3 ---------------------
---- find the name of top 3 spender of our system
SELECT
    top3spender,
    totalspent,
    top3receiver,
    totalincome
FROM (
    SELECT
        U.username AS top3spender,
        sum(B.total_booking_value * R.quantity) AS totalSpent,
        row_number() OVER (ORDER BY sum(B.total_booking_value * R.quantity) DESC) AS rownum
    FROM
        users U,
        booking B,
        reserve R
    WHERE
        B.individual_id = U.individual_id
        AND B.bid = R.bid
    GROUP BY
        U.username
    ORDER BY
        sum(B.total_booking_value * R.quantity) DESC
    LIMIT 3) t
    INNER JOIN (
        SELECT
            S.svcp_username AS top3receiver,
            sum(B.total_booking_value * R.quantity) AS totalIncome,
            row_number() OVER (ORDER BY sum(B.total_booking_value * R.quantity) DESC) AS rownum
        FROM
            svcp S,
            booking B,
            reserve R
        WHERE
            R.individual_id = S.individual_id
            AND B.bid = R.bid
        GROUP BY
            S.svcp_username
        ORDER BY
            sum(B.total_booking_value * R.quantity) DESC
        LIMIT 3) t2 ON t.rownum = t2.rownum;

