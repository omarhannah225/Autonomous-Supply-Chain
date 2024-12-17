;; Dispute Resolution Contract

(define-map disputes
  { dispute-id: uint }
  {
    product-id: uint,
    complainant: principal,
    respondent: principal,
    description: (string-utf8 500),
    status: (string-ascii 20),
    resolution: (optional (string-utf8 500))
  }
)

(define-data-var last-dispute-id uint u0)

(define-public (create-dispute (product-id uint) (respondent principal) (description (string-utf8 500)))
  (let
    (
      (dispute-id (+ (var-get last-dispute-id) u1))
    )
    (map-set disputes
      { dispute-id: dispute-id }
      {
        product-id: product-id,
        complainant: tx-sender,
        respondent: respondent,
        description: description,
        status: "open",
        resolution: none
      }
    )
    (var-set last-dispute-id dispute-id)
    (ok dispute-id)
  )
)

(define-public (resolve-dispute (dispute-id uint) (resolution (string-utf8 500)))
  (let
    (
      (dispute (unwrap! (map-get? disputes { dispute-id: dispute-id }) (err u404)))
    )
    (asserts! (is-eq tx-sender (get respondent dispute)) (err u403))
    (asserts! (is-eq (get status dispute) "open") (err u401))
    (map-set disputes
      { dispute-id: dispute-id }
      (merge dispute { status: "resolved", resolution: (some resolution) })
    )
    (ok true)
  )
)

(define-read-only (get-dispute-details (dispute-id uint))
  (ok (unwrap! (map-get? disputes { dispute-id: dispute-id }) (err u404)))
)

