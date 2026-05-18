class AppError extends Error {
  constructor(statusCode, message, details = undefined) {
    super(message);
    this.name = "AppError";
    this.statusCode = statusCode;
    this.details = details;
  }
}

function notFound(message) {
  return new AppError(404, message);
}

module.exports = {
  AppError,
  notFound,
};
