# Path
PROJECT_PATH = $(CURDIR)
SCRIPTS_PATH = $(PROJECT_PATH)/scripts/

# Prerequisites
PREREQUISITES_NAME = 	\
						getSpotifyAndroidSDK.sh \
						getSpotifyAppleSDK.sh

PREREQUISITES = $(addprefix $(SCRIPTS_PATH), $(PREREQUISITES_NAME))

# Special Chars
LOG_NOCOLOR = \033[0m
LOG_VIOLET = \033[1;35m
LOG_BLUE = \033[1;34m
LOG_CYAN = \033[1;36m
TITLE = $(LOG_VIOLET)
SUBTITLE = $(LOG_CYAN)
END_TITLE = $(LOG_NOCOLOR)

# Rules
.PHONY: all
all: init

.PHONY: init
init: prerequisites
	@echo "\n$(TITLE)Get flutter dependencies$(END_TITLE)"
	@flutter pub get

.PHONY: prerequisites
prerequisites:
	@echo "$(TITLE)Run prerequisites scripts$(END_TITLE)" 
	@$(foreach PREREQUISITES_NAME, $(PREREQUISITES_NAME), \
		echo "\n$(SUBTITLE) - $(PREREQUISITES_NAME)$(END_TITLE)"; \
		$(PREREQUISITES); \
	)

.PHONY: dartdoc
dartdoc:
	flutter pub run dartdoc

.PHONY: doc
doc:
	flutter pub run dhttpd --path doc/api

.PHONY: models
models:
	flutter pub run build_runner build --delete-conflicting-outputs   
