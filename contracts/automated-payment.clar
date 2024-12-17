;; Automated Payment Contract

(define-map payments
  { payment-id: uint }
  {
    product-id: uint,
    buyer: principal,
    seller: principal,
    amount: uint,
    status: (string-ascii 20)
  }
)

(define-data-var last-payment-id uint u0)

(define-public (create-payment (product-id uint) (seller principal) (amount uint))
  (let
    (
      (payment-id (+ (var-get last-payment-id) u1))
    )
    (map-set payments
      { payment-id: payment-id }
      {
        product-id: product-id,
        buyer: tx-sender,
        seller: seller,
        amount: amount,
        status: "pending"
      }
    )
    (var-set last-payment-id payment-id)
    (ok payment-id)
  )
)

(define-public (confirm-delivery (payment-id uint))
  (let
    (
      (payment (unwrap! (map-get? payments { payment-id: payment-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get buyer payment)) (err u403))
    (asserts! (is-eq (get status payment) "pending") (err u401))
    (try! (stx-transfer? (get amount payment) tx-sender (get seller payment)))
    (map-set payments
      { payment-id: payment-id }
      (merge payment { status: "completed" })
    )
    (ok true)
  )
)

(define-read-only (get-payment-details (payment-id uint))
  (ok (unwrap! (map-get? payments { payment-id: payment-id }) (err u404)))
)

