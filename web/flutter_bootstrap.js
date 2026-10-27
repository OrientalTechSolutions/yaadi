{{flutter_js}}
{{flutter_build_config}}

// Characters no bundled font covers render as boxes instead of making the
// engine fetch fallback fonts from fonts.gstatic.com (ARCHITECTURE.md
// section 10).
_flutter.loader.load({
  config: {
    fontFallbackBaseUrl: 'assets/fallback-fonts/',
  },
});
