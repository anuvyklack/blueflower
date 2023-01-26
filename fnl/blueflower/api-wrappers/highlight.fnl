(local api vim.api)
(local format string.format)
(local M {})

;;       default : boolean : Don't override existing definition.
;;            fg : string  : foreground
;;            bg : string  : background
;;            sp : string  : special - the color of various underlines.
;;         blend : integer : Between 0 and 100.  Override the blend level for
;;                         : a highlight group within the popupmenu or floating
;;                         : windows. 'pumblend' or 'winblend' must be set to take
;;                         : effect.
;;          bold : boolean
;;        italic : boolean
;; strikethrough : boolean
;;       reverse : boolean
;;      standout : boolean
;;     underline : boolean
;;     undercurl : boolean
;;   underdouble : boolean
;;   underdotted : boolean
;;   underdashed : boolean
;;     nocombine : boolean

(fn M.get [name]
  "Get highlight group specification."
  (let  [(ok? hl) (pcall api.nvim_get_hl_by_name  name  vim.o.termguicolors)]
    (when ok?
      (set hl.fg hl.foreground)
      (set hl.bg hl.background)
      (set hl.sp hl.special)

      (set hl.foreground nil)
      (set hl.background nil)
      (set hl.special nil)
      hl)))

(fn M.set [name hl-spec]
  "Set highlighting group in the global (0) namespace."
  (api.nvim_set_hl 0 name hl-spec))

(fn M.set-in-namespace [ns-id name hl-spec]
  "Set highlighting group in the particular namespace."
  (api.nvim_set_hl ns-id name hl-spec))

(fn M.activate-namespace [ns-id]
  "Set active namespace of highlights."
  (api.nvim_set_hl_ns ns_id))

M
