/*	$NetBSD: umodemvar.h,v 1.10 2019/04/20 05:53:18 mrg Exp $	*/

/*
 * Copyright (c) 1998 The NetBSD Foundation, Inc.
 * All rights reserved.
 *
 * This code is derived from software contributed to The NetBSD Foundation
 * by Lennart Augustsson (lennart@augustsson.net) at
 * Carlstedt Research & Technology.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE NETBSD FOUNDATION, INC. AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE FOUNDATION OR CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

struct umodem_softc {
	device_t		sc_dev;		/* base device */

	struct usbd_device *	sc_udev;	/* USB device */

	int			sc_ctl_iface_no;
	struct usbd_interface *	sc_ctl_iface;	/* control interface */
	int			sc_data_iface_no;
	struct usbd_interface *	sc_data_iface;	/* data interface */

	int			sc_cm_cap;	/* CM capabilities */
	int			sc_acm_cap;	/* ACM capabilities */

	int			sc_cm_over_data;

	usb_cdc_line_state_t	sc_line_state;	/* current line state */
	u_char			sc_dtr;		/* current DTR state */
	u_char			sc_rts;		/* current RTS state */

	device_t		sc_subdev;	/* ucom device */

	bool			sc_dying;	/* disconnecting */

	kmutex_t		sc_lock;
	kcondvar_t		sc_detach_cv;
	int			sc_refcnt;

	int			sc_ctl_notify;	/* Notification endpoint */
	struct usbd_pipe *	sc_notify_pipe; /* Notification pipe */
	usb_cdc_notification_t	sc_notify_buf;	/* Notification structure */
	u_char			sc_lsr;		/* Local status register */
	u_char			sc_msr;		/* Modem status register */
};

void umodem_common_childdet(struct umodem_softc *, device_t);
int umodem_common_attach(device_t, struct umodem_softc *,
			 struct usbif_attach_arg *, struct ucom_attach_args *);

int	umodem_get_caps(struct usbd_device *, int *, int *,
			usb_interface_descriptor_t *);

void	umodem_get_status(void *, int, u_char *, u_char *);
void	umodem_set(void *, int, int, int);
int	umodem_param(void *, int, struct termios *);
int	umodem_ioctl(void *, int, u_long, void *, int, proc_t *);
int	umodem_open(void *, int);
void	umodem_close(void *, int);
int	umodem_common_activate(struct umodem_softc *, enum devact);
int	umodem_common_detach(struct umodem_softc *, int);
