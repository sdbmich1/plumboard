# config file for pixi-specific api keys
PIXI_KEYS = YAML::load_file("#{Rails.root}/config/pixi_keys.yml")[Rails.env]
PXB_HOME_PAGE_KEYS = YAML::load_file("#{Rails.root}/config/pxb_home_page.yml")[Rails.env]
SLS_KEYS = YAML::load_file("#{Rails.root}/config/sls.yml")[Rails.env]
PIXI_FEE = PIXI_KEYS['pixi']['fee']
PIXI_PERCENT = PIXI_KEYS['pixi']['percent']
PIXI_TXN_PERCENT = PIXI_KEYS['pixi']['txn_percent']
BIZ_TXN_PERCENT = PIXI_KEYS['pixi']['biz_txn_percent']
PXB_TXN_PERCENT = PIXI_KEYS['pixi']['pxb_txn_percent']
PIXTER_PERCENT = PIXI_KEYS['pixi']['pixter_percent']
PIXI_BASE_PRICE = PIXI_KEYS['pixi']['base_price']
PIXI_PREMIUM_PRICE = PIXI_KEYS['pixi']['premium_price']
EXTRA_PROCESSING_FEE = PIXI_KEYS['pixi']['extra_processing_fee']
PIXI_DAYS = PIXI_KEYS['pixi']['days']
MIN_TXN_AMT = PIXI_KEYS['pixi']['min_txn_amt']
MAX_PIXI_AMT = PIXI_KEYS['pixi']['max_pixi_amt']
MAX_PIXI_SIZE = PIXI_KEYS['pixi']['max_pixi_size']
MAX_INV_QTY = PIXI_KEYS['pixi']['max_inv_qty']
PAYMENT_API = PIXI_KEYS['pixi']['payment_api']
CREDIT_CARD_API = PIXI_KEYS['pixi']['credit_card_api']
PIXIBOARD_INFO = PIXI_KEYS['pixi']['company_info']
PIXI_WEB_SITE = PIXI_KEYS['pixi']['host_address']
PIXI_POST = PIXI_KEYS['pixi']['pixi_post']
PIXI_VERSION = PIXI_KEYS['pixi']['version']
PIXI_EMAIL = PIXI_KEYS['pixi']['email']
SALES_TAX_MSG = PIXI_KEYS['pixi']['sales_tax_msg']
MAX_SALES_TAX = PIXI_KEYS['pixi']['max_sales_tax']
MIN_PPOST_DAYS = PIXI_KEYS['pixi']['min_ppost_days']
MAX_DISPLAY_DAYS = PIXI_KEYS['pixi']['max_display_days']
CONV_FEE_MSG = PIXI_KEYS['pixi']['conv_fee_msg']
SELLER_FEE_MSG = PIXI_KEYS['pixi']['seller_fee_msg']
BIZ_FEE_MSG = PIXI_KEYS['pixi']['biz_fee_msg']
PIXI_WANT_MSG = PIXI_KEYS['pixi']['pixi_want_msg']
PXPOST_FEE_MSG = PIXI_KEYS['pixi']['pxpost_fee_msg']
PIXI_POST_ZIP_ERROR = PIXI_KEYS['pixi']['zip_error_msg']
PIXI_CAPTION = PIXI_KEYS['pixi']['caption']
PIXI_POST_CAPTION = PIXI_KEYS['pixi']['px_post_caption']
PIXI_COMMENTS = PIXI_KEYS['pixi']['px_comments']
PIXI_POST_TAG_LINE = PIXI_KEYS['pixi']['pxpost_tag_line']
FB_WELCOME_MSG = PIXI_KEYS['pixi']['fb_welcome_msg']
NO_PIXI_FOUND_MSG = PIXI_KEYS['pixi']['no_pixi_found_msg']
NO_INV_PIXI_MSG = PIXI_KEYS['pixi']['no_inv_pixi_msg']
MIN_PIXI_COUNT = PIXI_KEYS['pixi']['min_pixi_count']
PIXI_LOCALE = PIXI_KEYS['pixi']['pixi_locale']
MIN_BOARD_AMT = PIXI_KEYS['pixi']['min_board_amt']
USE_LOCAL_PIX = PIXI_KEYS['pixi']['use_local_pix']
PIXI_CONTEST = PIXI_KEYS['pixi']['pixi_contest']
MAX_SHIP_AMT = PIXI_KEYS['pixi']['max_ship_amt']
PIXI_WIDTH = PIXI_KEYS['pixi']['pixi_width']
MIN_FEATURED_PIXIS = PIXI_KEYS['pixi']['min_featured_pixis']
MIN_FEATURED_USERS = PIXI_KEYS['pixi']['min_featured_users']
MAX_FEATURED_PIXIS = PIXI_KEYS['pixi']['max_featured_pixis']
MAX_FEATURED_USERS = PIXI_KEYS['pixi']['max_featured_users']
PIXI_DISPLAY_AMT = PXB_HOME_PAGE_KEYS['pixi']['pixi_count']
