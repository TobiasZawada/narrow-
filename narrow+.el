;;; narrow+.el --- Edit regions in indirect buffers. -*- lexical-binding: t -*-

;; Copyright (C) 2015  Tobias.Zawada

;; Author: Tobias.Zawada <i@tn-home.de>
;; URL: https://github.com/TobiasZawada/narrow+
;; Package-Version: 1.0
;; Package-Requires: ((emacs "24.4"))
;; Keywords: lisp

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Eval file-local variables in regions with command `narrow+-indirect-region'
;; and `narrow+-to-region-hack-local-vars'.  The the documentation of these
;; two functions for further information.

;;; Code:

(defvar-local narrow+-to-region-hack-local-vars 0
  "If larger than zero run `normal-mode' at `widen'.")
(put 'narrow-to-region-hack-local-vars 'permanent-local t)

(defun narrow+-widen (&rest _ignore)
  "Run `normal-mode' after `widen' if returning.
Used for command `narrow-to-region-hack-local-vars'."
  (when (> narrow+-to-region-hack-local-vars 0)
    (cl-decf narrow+-to-region-hack-local-vars)
    (normal-mode)))

(advice-add 'widen :around #'narrow+-widen)

;;;###autoload
(defun narrow+-to-region-hack-local-vars ()
  "Run `hack-local-variables' after `narrow-to-region'."
  (interactive)
  (if (use-region-p)
      (progn
	(narrow-to-region (region-beginning) (region-end))
	(cl-incf narrow+-to-region-hack-local-vars)
	(hack-local-variables))
    (error "Region is not active")))

;;;###autoload
(global-set-key (kbd "C-x n l") 'narrow+-to-region-hack-local-vars)

;; modified version of http://www.emacswiki.org/emacs/IndirectBuffers#IndirectRegion
;;;###autoload
(defun narrow+-indirect-region (start end)
  "Edit the current region from START to END in an new buffer.
Evaluate file local variables defined in the region."
  (interactive "r")
  (let ((buffer-name (generate-new-buffer-name (concat ">" (buffer-name) "<"))))
    (pop-to-buffer (make-indirect-buffer (current-buffer) buffer-name))
    (narrow-to-region start end)
    (hack-local-variables)
    (goto-char (point-min))
    (shrink-window-if-larger-than-buffer)))

;;;###autoload
(global-set-key (kbd "C-x n r") 'narrow+-indirect-region)

(provide 'narrow+)
;;; narrow+.el ends here
