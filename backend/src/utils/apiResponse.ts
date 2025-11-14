interface SuccessResponse<T> {
  success: true;
  data: T;
}

interface ErrorResponse {
  success: false;
  error: {
    message: string;
    details?: any;
  };
}

/**
 * @summary
 * Creates a standardized success response object.
 *
 * @param data The payload to be returned.
 * @returns A success response object.
 */
export function successResponse<T>(data: T): SuccessResponse<T> {
  return {
    success: true,
    data,
  };
}

/**
 * @summary
 * Creates a standardized error response object.
 *
 * @param message The error message.
 * @param details Optional additional details about the error.
 * @returns An error response object.
 */
export function errorResponse(message: string, details?: any): ErrorResponse {
  return {
    success: false,
    error: {
      message,
      details,
    },
  };
}
