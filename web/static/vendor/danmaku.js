(function(){

	var originalPlayFile = window.playfile;
	if (!originalPlayFile) return;

	var didObserveVjs = false;
	var elmMenu, elmCommentViewer;

	// Steal anilist id
	var currentAnilistId = (function() {
		var href = $('#poster a').attr('href');
		if (!href) return null;
		var paths = href.split('/');
		return parseInt(paths[paths.length-1]) || null;
	})();

	window.playfile = function() {
		var result = originalPlayFile.apply(this, arguments);
		if (!didObserveVjs) {
			didObserveVjs = true;
			var overlay = setupDanmakuOverlay();
			observeVjs(overlay);
		}
		updateMenuSrc(currentAnilistId);
		console.log('current env', currentAnilistId);
		return result;
	};

	// Hack the links
	$('.file').off('mouseup', originalPlayFile);
	$('.file').on('mouseup', playfile);

	var originalDisplayInfo = window.displayInfo;
	window.displayInfo = function(src) {
		currentAnilistId = src.id;
		return originalDisplayInfo.apply(this, arguments);
	};

	function observeVjs(overlay) {
		var vjs = window.vjs;

		vjs.on('play', function() {
			overlay.play();
		});

		vjs.on('pause', function() {
			overlay.pause();
		});

		vjs.on('waiting', function() {
			console.log('waiting');
			overlay.pause();
		});
		vjs.on('waitEnd', function(){
			console.log('wait end');
			overlay.play();
		});

		vjs.on('ended', function() {
			overlay.stop();
		});

		vjs.on('timeupdate', function () {
			overlay.updateTime(vjs.currentTime());
		});
	}

	function setupDanmakuOverlay() {
		var container = $('#player');
		if (!container.length || !window.vjs) {
			console.warn('Cannot find container/videojs');
			return;
		}

		var danmakuOverlay = $('<div>')
		.css({
			left: 0,
			top: 0,
			width: '100%',
			height: '100%',
			position: 'absolute',
			'pointer-events': 'none',
		})
		.appendTo(container);

		var danmakuButton = vjs.controlBar.addChild('button', {
		  text: "Danmaku",
		});
		danmakuButton.addClass("vjs-danmaku-control");
		var danmakuDom = $(".vjs-danmaku-control")
			.attr('title','Danmaku')
			.insertAfter($(".vjs-fill-control"));

		var commentViewer = Elm.CommentViewer.embed(danmakuOverlay.get(0));
		var menu = Elm.Menu.embed(danmakuDom.get(0), {
			anilistId: -1,
			filename: ""
		});
		menu.ports.comments.subscribe(function(comments) {
			commentViewer.ports.slidingComments.send(comments);
		});

		elmMenu = menu;
		elmCommentViewer = commentViewer;

		$('<link href="https://danmaku.b123400.net/css/danmaku.css" rel="stylesheet" type="text/css">')
		.appendTo("head");

		return {
			play: function(){
				commentViewer.ports.setPlayState.send(true);
			},
			stop: function(){
				commentViewer.ports.setPlayState.send(false);
				commentViewer.ports.setTime.send([0, Date.now()]);
			},
			pause: function(){
				commentViewer.ports.setPlayState.send(false);
			},
			updateTime: function(seconds){
				commentViewer.ports.setTime.send([seconds, Date.now()]);
			}
		}
	}

	function updateMenuSrc(anilistId) {
		var currentSource = vjs.currentSrc();
		var paths = currentSource.split('/');
		var filename = paths[paths.length-1];
		if (!filename) return;

		setTimeout(function() {
			elmMenu.ports.flags.send({
				anilistId: anilistId || -1,
				filename: decodeURIComponent(filename)
			});
		}, 0);
	}

})();
