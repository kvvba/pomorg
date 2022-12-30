;;; pomorg.el --- Pomodoro timer using org-timer

;;; Commentary:

;; This file implements a pomodoro timer into Emacs using
;; built-in timer capabilities of org mode.

;;; Code:

(require 'org-clock)
(require 'org-element)

(defvar pomo-work-periods 8)

(defvar pomo-work-periods-remaining pomo-work-periods)

(defvar pomo-time-work "00:50:00")

(defvar pomo-time-break "00:10:00")

(defvar pomo-time-long-break "00:30:00")

(defvar pomo-long-break-interval 4)

(defvar pomo-current-period "break")

(defun pomo-start (&optional n)
	"Set pomo-periods to N, begin pomodoro timer."
	(interactive "nNumber of pomodoros: ")
	(setq pomo-work-periods-remaining n)
	(setq pomo-work-periods n)
	(setq pomo-current-period "break")
	(pomo-run-next)
	(add-hook 'org-timer-done-hook 'pomo-run-next))

(defun pomo-run-next ()
	"Choose appropriate pomodoro timer to run and run it."
	(if (<= pomo-work-periods-remaining 0)
			(pomo-end)
		(cond ((or (equal pomo-current-period "break") (equal pomo-current-period "long break"))
					 (pomo-run-work))
					((equal pomo-current-period "work")
					 (if (= (% (- pomo-work-periods pomo-work-periods-remaining) pomo-long-break-interval) 0)
							 (pomo-run-long-break)
						 (pomo-run-break))))))

(defun pomo-run-long-break ()
	"Run long break period."
	(interactive)
	(setq pomo-current-period "long break")
	(message "Time for a long break (%s)." pomo-time-long-break)
	(org-timer-set-timer pomo-time-long-break))

(defun pomo-run-break ()
	"Run break period."
	(setq pomo-current-period "break")
	(message "Time for a break.")
	(org-timer-set-timer pomo-time-break))

(defun pomo-run-work ()
	"Run work period if there are pomodoros left."
	(setq pomo-current-period "work")
	(org-timer-set-timer pomo-time-work)
	(message "Time to focus. %s/%s periods completed." (- pomo-work-periods pomo-work-periods-remaining) pomo-work-periods)
	(setq pomo-work-periods-remaining (1- pomo-work-periods-remaining)))

(defun pomo-end ()
	"Signal end of pomodoros."
	(message "Pomodoros complete.")
	(remove-hook 'org-timer-done-hook 'pomo-run-next))

(defun pomo-pause-or-continue ()
	"Pause or continue pomodoro timer."
	(interactive)
	(org-timer-pause-or-continue))

(defun pomo-show-remaining ()
	"Print number of remaining pomodoros as message."
	(interactive)
	(message "%s/%s pomodoros remaining." pomo-work-periods-remaining pomo-work-periods))

(defun pomo-show-completed ()
	"Print number of completed pomodoros as a message."
	(interactive)
	(message "%s/%s pomodoros completed." (- pomo-work-periods pomo-work-periods-remaining) pomo-work-periods))

(defun pomo-show-period ()
	"Print current pomodoro time period (work/break/long break)."
	(interactive)
	(message "Current pomodoro period: %s." pomo-current-period))

(defun pomo-stop ()
	"Stops the pomodoro timer."
	(interactive)
	(org-timer-stop))

(provide 'pomorg)
;;; pomorg.el ends here
