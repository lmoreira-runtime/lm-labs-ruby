require 'dotenv'
require 'logger'
require 'json'

# Load environment variables from .env file if it exists
Dotenv.load('.env')

# Paths
PROJ_ROOT = File.expand_path('..', __dir__)

# Logger setup
logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG

# Set up JSON formatter for logger
class JsonLogger < Logger::Formatter
  def call(severity, time, progname, msg)
    {
      severity: severity,
      time: time.utc.strftime('%Y-%m-%dT%H:%M:%S.%LZ'),
      progname: progname,
      message: msg
    }.to_json + "\n"
  end
end

logger.formatter = JsonLogger.new

logger.debug("PROJ_ROOT path is: #{PROJ_ROOT}")

DATA_DIR = File.join(PROJ_ROOT, 'data')
RAW_DATA_DIR = File.join(DATA_DIR, 'raw')
INTERIM_DATA_DIR = File.join(DATA_DIR, 'interim')
PROCESSED_DATA_DIR = File.join(DATA_DIR, 'processed')
EXTERNAL_DATA_DIR = File.join(DATA_DIR, 'external')

MODELS_DIR = File.join(PROJ_ROOT, 'models')
REPORTS_DIR = File.join(PROJ_ROOT, 'reports')
FIGURES_DIR = File.join(REPORTS_DIR, 'figures')

GITHUB_ACCESS_TOKEN = ENV['GITHUB_ACCESS_TOKEN']
GITHUB_OWNER = ENV['GITHUB_OWNER']
GITHUB_REPO = ENV['GITHUB_REPO']
GITHUB_USERNAME = ENV['GITHUB_USERNAME']
GITHUB_API_BASE_URL = 'https://api.github.com'

LITELLM_MASTER_KEY = ENV['LITELLM_MASTER_KEY']
LITELLM_API_KEY = ENV['LITELLM_API_KEY']

OPENAI_API_KEY = ENV['OPENAI_API_KEY']
GEMINI_API_KEY = ENV['GEMINI_API_KEY']
COHERE_API_KEY = ENV['COHERE_API_KEY']
GROQ_API_KEY = ENV['GROQ_API_KEY']

ACTIVELOOP_TOKEN = ENV['ACTIVELOOP_TOKEN']

DATABASE_URL = ENV['DATABASE_URL']

POLYGLOT_DIR = File.join(PROJ_ROOT, 'labs', 'polyglot_data')

SPACY_MODELS = [
  { "language_code" => "pt", "language_name" => "portuguese", "model" => "pt_core_news_lg" },
  { "language_code" => "en", "language_name" => "english", "model" => "en_core_web_md" }
]

SUMMARIZATION_MODEL = "facebook/bart-large-cnn"

def get_logger(module_name)
  Logger.new(STDOUT).tap do |logger|
    logger.progname = module_name
  end
end
